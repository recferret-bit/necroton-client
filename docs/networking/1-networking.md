### Overview

This document defines a complete, deterministic flow for accepting server inputs into the simulation engine, applying local client prediction, reconciling authoritative state, and running a local server-emulator mode so the same codebase supports singleplayer and multiplayer with minimal changes. The design enforces an authoritative server tick loop, fixed-timestep simulation, idempotent input sequences, deterministic RNG, snapshot anchors, and smooth visual correction strategies.

---

### Communication model and guarantees

- Transport is bidirectional reliable-ordered stream for control messages and UDP-like lower-latency channel for high-frequency inputs when available. Use WebSocket or reliable JetStream for control and NATS/UDP or WebRTC data channels for inputs and snapshots as needed.  
- Server is authoritative for game state. Clients send intents only. Server validates and applies intents on specific authoritative ticks.  
- All simulation logic runs on a fixed tick defined as tickDuration = 1 / tickRate. All messages referencing time use tick numbers and epoch-ms timestamps for diagnostics.  
- Every input is identified by clientId and inputSequence. Every snapshot references serverTick and ackedInputSequence per client.  
- Deterministic RNG seed is per-match and included in initial handshake and snapshots. The RNG state is part of snapshot serialization.  
- The system supports eventual consistency and reconciliation. Clients locally predict authoritative effects and accept server corrections from snapshots or event messages.

---

### Message contracts (compact)

- Client -> Server: InputMessage
  - clientId: string
  - inputSequence: int
  - clientTick: int
  - intendedServerTick: int
  - timestampMs: int64
  - movement: { moveX: float, moveY: float, jump: bool, sprint: bool }
  - view: { yaw: float, pitch: float }
  - actions: [ { actionId: string, actionSequence: int, params: object, startedAtClientTick: int } ]
- Server -> Client: InputAck
  - clientId: string
  - inputSequence: int
  - appliedServerTick: int
  - serverTimeMs: int64
- Server -> Client: SnapshotMessage
  - serverTick: int
  - serverTimeMs: int64
  - ackedInputSequences: map<string,int>
  - authoritativeEntities: [ { entityId:int, position:{x,y}, velocity:{x,y}, rotation:float, state:object } ]
  - transientColliders: [ ... ]
  - events: [ { eventId:string, type:string, payload:object, serverTick:int } ]
  - rngState: bytes
- Server -> Client: EventMessage
  - serverTick: int
  - eventId: string
  - type: string
  - payload: object
- Client -> Server: PredictionCorrectionRequest (optional diagnostic)
  - clientId, inputSequence, localStateHash, optional replay payload

Design notes:
- Snapshots are authoritative deltas. Optimize with interest management and delta compression.  
- Include ackedInputSequences so client knows which local inputs server consumed.

---

### Full client-side pipeline

1. Local simulation instance initialization  
   - Initialize SimulationCore with same deterministic rules as server.  
   - Load match seed, deterministic RNG, match config, colliders, spawn points, and initial snapshot if provided.  
   - Maintain a pendingInputs buffer and a localState versioned by clientTick and predictedTick.

2. Capture input and immediate local prediction  
   - On player input, increment inputSequence and clientTick.  
   - Create InputMessage and add to pendingInputs buffer.  
   - Immediately apply input to local SimulationCore for prediction at local predicted tick.  
   - Render results instantly to preserve responsiveness.

3. Send input to server  
   - Batch movement and actions into a single InputMessage at configured clientSendRate.  
   - Include intendedServerTick mapped via server clock offset.  
   - Attach inputSequence and per-action actionSequence for idempotency.  
   - Transmit using chosen transport.

4. Receive InputAck and Snapshot  
   - On InputAck, mark pending inputs <= inputSequence as acknowledged for that client.  
   - On SnapshotMessage, compare authoritative entity states to local predicted states anchored at snapshot.serverTick.  
   - Snapshot includes ackedInputSequences per client, transient colliders and events executed on serverTick.

5. Reconciliation algorithm (server snapshot arrives)  
   - If snapshot.serverTick <= lastAppliedServerTick ignore as stale.  
   - Save snapshot as authoritativeAnchor at serverTick.  
   - Derive the local set of pendingInputs that occurred after ackedInputSequence for this client.  
   - Replace local SimulationCore state with authoritativeAnchor state.  
   - Replay pendingInputs in order through SimulationCore deterministically until current tick.  
   - Compute per-entity deltas between authoritative and replayed states.  
   - For each owned player entity apply smoothing: set authoritative transform as target and blend local visuals by interpolation over correctionSmoothingMs.  
   - For non-owned remote entities replace visuals with server-authoritative values using interpolation or extrapolation based on network conditions.

6. Handling discrete action results and visual effects  
   - Treat actions as intents that may spawn transient colliders, projectiles or events on server tick.  
   - Client predicts immediate start of cast animation and optionally spawns local provisional projectiles flagged provisionalId.  
   - When server publishes the authoritative event containing created entity ids, map provisionalId to authoritative entityId or discard provisional and play authoritative VFX.  
   - For rejected actions server sends EventMessage with fail reason and optionally refunded resource events.

7. Latency and jitter mitigation  
   - Maintain client clock offset estimate using server_hello and periodic pings.  
   - Use inputSequence and appliedServerTick to measure roundtrip and correct intendedServerTick mapping.  
   - Use interpolation buffer for remote entities with latency cushion of interpolationMs = clamp(avgRTT, minInterp, maxInterp).  
   - Use packet loss tolerance: if snapshot missed for N ticks, continue extrapolation and keep local pending inputs.

8. Anti-cheat validation and server authority  
   - Server ignores positions and trust only inputs as intentions.  
   - Server enforces movement speed, acceleration, cooldowns and reagent constraints before applying actions.  
   - Clients must not be allowed to claim direct instantiation of important state; server always publishes authoritative entity creation and deletion events.

---

### Server integration pipeline and authoritative loop

1. Server tick loop runs at fixed tickRate; each tick:
   - Collect inputs addressed to this tick from transport buffer.  
   - Validate each InputMessage for rate limits, syntactic correctness and anti-cheat heuristics.  
   - Convert input intent to internal action queue for this tick.  
   - Execute MovementSystem, PhysicsSystem, ActionSystem in deterministic order.  
   - Execute RuleManager for win conditions and spawn management.  
   - Generate SnapshotMessage for clients containing authoritative deltas and ackedInputSequences per client.  
   - Publish EventMessages for discrete important results like attack:hit, spawn:entity, death.

2. Input scheduling  
   - Map clientTick to serverTick using handshake offset or compute intendedServerTick from input payload.  
   - Define maximum allowed ahead-of-server input window and apply clamping.  
   - Late inputs are either applied next tick with logged warning or rejected.

3. Snapshot frequency  
   - Send full snapshots every N ticks and delta snapshots every tick for bandwidth efficiency.  
   - Include ackedInputSequences to help clients drop confirmed inputs.

4. Event ordering and idempotency  
   - Use monotonic event ids and include original inputSequence or actionSequence in events to allow clients to dedupe.  
   - Ensure events needed for client-side mapping include provisionalId mapping support for client-predicted entities.

---

### Server-emulation mode on the client

Design goals:
- Single codebase for SimulationCore that can run either in client-prediction-only mode or local-authoritative server-emulation mode.  
- Server-emulation mode executes a local authoritative simulation loop and uses the exact server loop code so clients and server share deterministic logic.

Implementation details:
- Expose SimulationCore with two runtime modes: Mode.Predictive and Mode.Authoritative.  
- Mode.Predictive responsibilities:
  - Runs simulation steps driven by render loop predictions and pending inputs.
  - Sends InputMessages to a remote server.
  - Accepts snapshots and performs reconciliation.

- Mode.Authoritative responsibilities (server-emulation):
  - Does not send InputMessages externally.  
  - Instead of remote server, the local SimulationCore accepts inputs from local clients and processes them in the authoritative loop.  
  - The same logic that would serialize snapshots for network transmission serializes to an internal event bus.  
  - UI and network stacks subscribe to that bus the same way as a remote client would subscribe to real network messages.

- Mode switching:
  - Provide a small network abstraction interface INetworkLayer with methods sendInput(Input) and subscribeToSnapshots(handler).  
  - Implement RemoteNetworkLayer that actually sends over WebSocket.  
  - Implement LocalLoopbackNetworkLayer that forwards inputs immediately to local authoritative SimulationCore and returns snapshots/events to local client after processing.  
  - Create a bootstrap that instantiates either RemoteNetworkLayer or LocalLoopbackNetworkLayer based on runtime flag.

Benefits:
- Single SimulationCore implementation is used for server and client prediction.  
- Single code path for action handling, collision, CCD and ephemeral colliders.  
- Fast offline testing and deterministic replay.

---

### Practical reconciliation and smoothing strategies

- Correction policy thresholds:
  - Positional snap threshold in world units. If position error > hardSnapThreshold then instantly set authoritative position.  
  - Otherwise apply linear interpolation to authoritativePosition over correctionSmoothingMs.  
  - Velocity is replaced with authoritative velocity to avoid runaway divergence.

- Visual smoothing approaches:
  - Interpolation over multiple frames using lerp with alpha = frameDt / correctionSmoothingMs.  
  - Hermite or cubic smoothing for higher-quality corrections when available.

- Action/animation reconciliation:
  - If predicted action results match server outcome do nothing.  
  - If the server modified result (e.g., different hit target) play a corrective FX sequence and apply authoritative state.  
  - Keep client-side provisional VFX for immediate responsiveness but tag them with provisionalId and replace with authoritative when event arrives.

- Handling entity id mapping:
  - Client predicts spawns with provisional negative ids.  
  - Server event includes provisionalId mapping or authoritative entityId in spawn result.  
  - On mapping arrival transform local entity id to authoritative id and update all references.

---

### Implementation checklist and sample flow example

1. Implement SimulationCore and ensure deterministic rules.  
2. Implement INetworkLayer abstraction with Remote and LocalLoopback variants.  
3. Implement Input sequence buffer and clientSendRate batching.  
4. Implement snapshot handler with ackedInputSequences and restore/replay logic.  
5. Implement smoothing helper utilities and correction thresholds.  
6. Implement provisional spawn id mapping and attack collider dedupe.  
7. Create test harness: run LocalLoopbackNetworkLayer and assert parity between pure authoritative ticks and predicted client state after random inputs.  
8. Integrate telemetry to measure RTT, serverTick lag, correction frequencies and mean positional drift.

Sample time-ordered flow:
- t0 client generates Input seq 100, applies locally to predicted tick 501 and sends to server.  
- t1 network delivers Input to server and server applies at serverTick 501, producing snapshot serverTick 501 that includes ackedInputSequence=100 and events for spell_cast.  
- t2 client receives snapshot, sees ackedInputSequence 100 and authoritative player position at tick 501. Client loads authoritative anchor at tick 501, replays inputs >100 if present, computes correction delta and applies smoothing over next frames.

This design provides a single deterministic engine code path for both local server-emulation and remote-authoritative multiplayer while delivering low-latency client experience through prediction and robust authoritative reconciliation.
