**Planning documentation structure**

I need to map the MVP client-side integration with engine concepts. I'll organize the documentation into clear sections with headings from H1 to H5. Maybe six sections total, with a focus on structure and clarity, such as Overview, Architecture Mapping, Core View Classes, Presenter Classes, Integration Patterns, and Implementation Checklist. Each section will have concise but comprehensive content, covering things like eventbus integration, UI, input, predictions, and testing. I'll ensure headings are specific and avoid redundancy, staying direct with labels and lists, plus no system prompt details.
### Overview

This document describes how to integrate the deterministic SimulationEngine (Model) into a Heaps.io client while keeping the same MVP separation used in the engine: Model (unchanged engine core), Presenter (client-side orchestrator and reconcilers), View (Heaps rendering, audio, UI). The client is rendering- and audio-focused but must remain a passive consumer of engine events and snapshots so the same model code runs unchanged in singleplayer (loopback) and multiplayer (remote) modes.

---

### Architecture mapping

- Model
  - **What**: Existing SimulationEngine, GameModelState, GameEventBus, GameSnapshotStore and per-type stores.
  - **Where**: Run in a separate module imported by the client (Haxe core lib or via wasm/TS bridge).
  - **Constraint**: Model must not reference any Heaps types; it emits events and snapshots only.

- Presenter
  - **What**: Client-side orchestrator(s) that adapt Model events to UI and rendering and forward local inputs to the network gateway.
  - **Responsibilities**: input capture and sequencing, client prediction, reconciliation, mapping provisional IDs, smoothing corrections, scene lifecycle, mode switching (loopback vs remote), performance orchestration.
  - **Instance**: GamePresenter (single), InputPresenter, ReconciliationPresenter, AudioPresenter, UIController.

- View
  - **What**: Heaps-specific rendering and audio; subscribe-only to GameEventBus and snapshot topics exposed by engine through INetworkGateway or loopback.
  - **Responsibilities**: create/destroy nodes, animate, play audio, show UI overlays, debug visualizations, scene transitions.
  - **Instance**: GameViewAdapter, SceneManager, AudioManager, UISceneManager, DebugOverlay.

---

### Core client classes and their MVP role

- Model classes (no Heaps dependency)
  - SimulationEngine, GameModelState, GameSnapshotStore, GameEventBus.

- Presenter classes (glue between Model and View)
  - GamePresenter
    - start(), stop(), switchMode(mode), registerView(view)
    - subscribes to network snapshots; triggers reconciliation
  - InputPresenter
    - captureKeyMouse(), captureTouch(), localPredictionApply(), batchAndSend()
  - ReconciliationPresenter
    - onSnapshot(), rollbackAndReplay(), computeCorrections(), triggerViewSmoothing()
  - AudioPresenter
    - receive action:event & snapshot events; decide sounds to play
  - UIController
    - manages HUD and top-layer UI scenes; handles menu/overlay events

- View classes (Heaps integration)
  - GameViewAdapter
    - subscribe to engine.viewBus topics; map EntityPayload -> Heaps nodes
    - applySnapshot(snapshot), applyDelta(delta), smoothEntityCorrection(entityId, targetState, durationMs)
  - SceneManager
    - Scene stack: MainScene, UI scenes, Overlay scenes
    - lifecycle hooks: enterScene, leaveScene, update, fixedRenderTick
  - EntityView
    - prefab binding, animation controller, VFX spawner, sound hooks
  - AudioManager
    - 2D/3D sound wrappers, pooling, priority management
  - UISceneManager
    - stack of UI scenes on top of main scene, handles input focus
  - DebugOverlay
    - draws colliders, spawn points, hitboxes, event logs (driven from GameEventBus)

---

### Events, subscriptions and view-side API

- Subscribe only; never modify model state from View.
- Use the same event topics as engine:
  - entity:spawn → GameViewAdapter.createNode
  - entity:kill → GameViewAdapter.playDeathVFX + destroy node
  - action:intent → View plays provisional VFX/animation
  - action:resolved → View reconciles hit VFX, spawn authoritative entities
  - snapshot:full / snapshot:delta → GameViewAdapter.applySnapshot
  - input:ack → InputPresenter drop acknowledged inputs
  - game:condition / game:objective → UIController present results
- Provide filtered subscription helpers on GameViewAdapter:
  - subscribeForEntity(entityId, topic)
  - subscribeForTeam(teamId, topic)
- Provide batching for high-frequency updates:
  - topic positions:update with array of {id,x,y,rot} at render tick rate

---

### Client-side workflows

1. Start and boot
   - Presenter creates SimulationEngine or connects to remote engine via INetworkGateway.
   - SceneManager loads assets and UI scenes. View registers GameViewAdapter to engine.viewBus or network snapshots.

2. Input flow (singleplayer or multiplayer)
   - InputPresenter captures raw input from Heaps Input API.
   - Builds Input message (clientTick, inputSequence).
   - Calls InputPresenter.localPredictApply(input) → delegates to SimulationEngine.applyLocalInput or pushes into local predictive Simulation instance.
   - Sends input via NetworkPresenter (Loopback or RemoteNetworkGateway).
   - View plays provisional animation/VFX for responsiveness.

3. Snapshot arrival and reconciliation
   - NetworkPresenter receives snapshot → calls ReconciliationPresenter.onSnapshot(snapshot).
   - ReconciliationPresenter loads authoritative anchor from GameSnapshotStore, computes pending inputs, calls SimulationEngine.rollbackAndReplay(anchorTick, pendingInputs).
   - Computes per-entity correction deltas and calls GameViewAdapter.smoothEntityCorrection(entityId,...).
   - UIController receives game:condition or action:resolved events and updates HUD.

4. Entity lifecycle and visuals
   - engine emits entity:spawn → GameViewAdapter creates Node, attaches EntityView script, loads sprite, animations.
   - engine emits entity:kill → GameViewAdapter triggers death animation and schedules node removal after VFX.
   - For temporary hit colliders and projectile spawns, View maps transient entity ids (or provisional negative IDs) to visual effects and reconciles when authoritative id arrives.

5. Scene transitions and UI layers
   - SceneManager controls main gameplay scene and overlays UI scenes atop.
   - UI scenes subscribe to GameEventBus for HUD updates, scoreboard, and match-end overlays.
   - Input routing: UI scenes can claim input focus; InputPresenter must ask UISceneManager whether input should be routed to UI or gameplay.

---

### Integration patterns and best practices

- Engine view surface
  - The engine exposes a typed EventBus (engine.viewBus) and snapshot publisher. The client registers handlers at startup.
- Prefab and visual factory
  - Use a PrefabRegistry mapping entity type/canonicalId → visual prefab (sprite frames, animation graph, VFX keys).
  - PrefabFactory returns an EntityView that knows how to bind to incoming EntityPayload and update transforms at render tick.
- Provisional IDs and mapping
  - Client prediction spawns provisional negative IDs for predicted spawns. Presenter keeps a provisionalIdMap to replace them with authoritative ids when action:resolved or spawn events arrive.
- Smoothing and interpolation
  - Use two layers: authoritative position (server) for replay, and visual interpolation for render frames.
  - Implement a smoothing helper in GameViewAdapter:
    - If delta > hardSnapThreshold then snap; otherwise lerp over correctionMs.
- Audio and VFX decoupling
  - AudioManager subscribes to same events but uses its own throttles for repeated SFX (e.g., limit same SFX within X ms).
- Interest management
  - For larger maps, subscribe only to nearby entities for VFX updates or use spatial culling in GameViewAdapter.
- Performance
  - Pool frequently created Heaps nodes (bullets, particles) via a NodePool.
  - Batch transforms (update many node positions in one pass) to reduce GC and render overhead.

---

### Example class skeletons for Heaps client

- GameViewAdapter
  - applySnapshot(snapshot)
  - onEntitySpawn(payload)
  - onEntityKill(payload)
  - smoothEntityCorrection(id, targetState, durationMs)
  - update(deltaMs) // called from Scene update

- SceneManager
  - pushScene(sceneId)
  - popScene()
  - update(deltaMs)

- PrefabFactory
  - createEntityView(entityPayload) -> EntityView

- EntityView
  - bindToEntity(entityPayload)
  - updateVisual(interpAlpha)
  - playVFX(key, params)
  - playSFX(key, params)

- InputPresenter
  - captureKeyboard()
  - captureGamepad()
  - sendLocalInput()
  - handleInputAck(payload)

- NetworkPresenter
  - sendInput(input)
  - onSnapshot(handler)
  - switchToLoopback(engine)

- ReconciliationPresenter
  - onSnapshot(snapshot)
  - computePending()
  - call engine.rollbackAndReplay(anchor, pending)

---

### Implementation checklist and timeline

1. Bootstrapping (1–2 days)
   - Wire SimulationEngine viewBus to the client startup path.
   - Implement GameViewAdapter subscribe layer and simple entity spawn/kill handlers.

2. Prefabs and visuals (2–3 days)
   - Build PrefabRegistry, PrefabFactory, EntityView base class, NodePool.

3. Input and prediction (2–3 days)
   - Implement InputPresenter local prediction apply and NetworkPresenter loopback.

4. Reconciliation and smoothing (2–4 days)
   - Implement ReconciliationPresenter, soft-correction, provisional id mapping.

5. Audio, VFX and UI layers (2–4 days)
   - Implement AudioManager, UISceneManager, integrate with event topics.

6. Polishing and profiling (2–3 days)
   - Implement interest culling, batch updates, and Node pooling optimizations.

---

### Testing and debug tools

- Replay recorder: record inputs + snapshots to replay sessions locally.
- Debug overlay: show colliders, spawn points, provisional ids, predicted vs authoritative paths.
- Deterministic parity tests: run the same input sequence in loopback mode and compare engine snapshots vs remote authoritative run.
- Visual smoke tests: assert no missing nodes after spawn/kill bursts; measure memory of node pool.

---

### Final notes

- Keep the Model pure and the View passive. Presenter must be the single component that touches Model mutably for prediction and reconciliation.
- Reuse the EventBus payloads and snapshot schema from the engine to avoid duplicate translation logic.
- Favor small, well-tested adapters: PrefabFactory, EntityView and Smoothing helpers will contain most Heaps-specific code.
- Start with a minimal visual mapping (circle sprites) and iterate to full VFX once the reconciliation and polling are rock-solid.

If you want, I can generate Haxe skeleton files for GameViewAdapter, SceneManager, EntityView base class and a NodePool implementation to drop directly into your Heaps project.
