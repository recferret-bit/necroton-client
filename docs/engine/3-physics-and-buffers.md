**Planning documentation structure**

Okay, I need to create documentation based on developer instructions. The structure should be simple, with a maximum of six sections. I can’t include system prompts or tool information, just a concise yet detailed design. I’ll include things like collider schemas, physics resolution techniques, and relevant modules. So, I’ll cover collision detection algorithms, input buffers, and state management, and use some pseudocode. I need to keep it clear but not overly detailed, maybe using types like in Haxe. It looks like the six sections will be Overview, Collider Models, PhysicsModule Design, EntityManager Integration, Buffers, and Examples.
### Overview

This document specifies the configurable physics and collider subsystem for the portable NecroTon engine. It covers collider data models (circle + polygon), collision detection (broadphase + narrowphase), collision resolution, integration with the generic EntityManager registry, determinism requirements, and the input / server-state buffering scheme used to apply client inputs by tick. The design is language-agnostic but includes Haxe/TypeScript-friendly typedefs, API signatures, and pseudocode for core algorithms.

---

### Collider models and configuration

#### Collider types
- CircleCollider
  - id: string|int
  - ownerEntityId: int
  - offset: Vec2 (local-space)
  - radius: Float
  - isTrigger: Bool
  - layer: Int (bitmask)
  - collisionMask: Int (bitmask)
  - durationTicks?: Int | null (for transient colliders)
  - meta?: object

- PolygonCollider (convex polygon only)
  - id: string|int
  - ownerEntityId: int
  - offset: Vec2 (local-space)
  - vertices: Array<Vec2> (ordered CCW in local-space; must be convex)
  - rotation: Float (local rotation relative to entity)
  - isTrigger: Bool
  - layer: Int
  - collisionMask: Int
  - durationTicks?: Int | null
  - meta?: object

Notes:
- Use convex polygons exclusively in physics narrowphase for deterministic SAT-based resolution and performance. Support for concave shapes via decomposition into convex parts at authoring time.
- All numeric fields are deterministic primitives (Float or Int); avoid any platform-dependent math (consistent RNG, same math lib across ports).

#### Vec2 typedef
- Vec2 = { x: Float, y: Float }

#### Collider schema constraints
- Polygon vertices must be provided in counter-clockwise order; polygon must be simple and convex.
- Collider offset + owner transform defines world transform: worldPos = entity.pos + rotate(offset, entity.rotation) and worldVertices = rotate(vertices, entity.rotation + collider.rotation) + worldPos.

---

### PhysicsModule: responsibilities and API

Responsibilities:
- Integrate entity velocities into positions each fixed tick.
- Maintain spatial index (broadphase) and provide collision pairs.
- Run narrowphase detection for circle-circle, circle-polygon, polygon-polygon.
- Produce contact info (penetration depth, contact normal, contact points) deterministically.
- Resolve collisions via position correction and velocity impulses (or simple positional separation for game-feel).
- Spawn and manage transient colliders (attacks, AoE) and emit physics events via EventBus.
- Work against the GameModelState and the central EntityManager registry; never depend on view code.

Key API (pseudotype)
- init(state: GameModelState, registry: ModuleRegistry, bus: EventBus): Void
- integrate(state: GameModelState, dt: Float): Void
- stepCollision(state: GameModelState, tick: Int): Void
- createTransientCollider(spec: ColliderSpec): String
- registerCollider(collider: Collider): Void
- unregisterCollider(colliderId: String): Void
- setCollisionLayerRules(layer: Int, mask: Int): Void

Determinism notes:
- Use fixedDt and integer ticks as timing source.
- Use deterministic floating point math policy (consistent epsilon, stable sorts where needed).
- Avoid iteration over unordered maps for physics-critical loops; if iteration is necessary, iterate over stable-sorted lists.

---

### Collision pipeline

#### 1) Broadphase
- Purpose: reduce O(n^2) pair checks to candidate pairs.
- Data structure: uniform spatial hash grid keyed by integer cells (cellSize tuned to average collider size). Deterministic iteration: maintain an ordered list of occupied cells and iterate cells sorted by hash id.
- Steps:
  - For each active collider compute its AABB in world space.
  - Insert collider id into all overlapping grid cells.
  - For each cell, produce pairs (i,j) where i < j and layer/mask allow collision.
  - Store unique pairs using ordered (min,max) tuple set to dedupe.

Advantages: simple, deterministic, fast, easy to implement in Haxe/TS.

#### 2) Narrowphase
- Supported primitive tests:
  - circle vs circle
  - circle vs convex polygon
  - polygon vs polygon (convex only)
- Use Separating Axis Theorem (SAT) for polygon-related tests and simple distance check for circle-circle.
- Output: Contact struct { aId, bId, penetration:Float, normal:Vec2 (from A to B), contactPoint:Vec2 (approx) }.

Collision detection pseudocode notes:
- For circle-polygon, project circle center onto polygon axes (normals of polygon edges) and include axis from circle center to nearest polygon vertex.
- For polygon-polygon, test all edge normals of both polygons.
- When computing penetration and normal choose the smallest penetration axis as collision manifold axis.

All tests return earliest axis and penetration depth; if any axis separates (projA.max < projB.min) then no collision.

#### 3) Contact generation and manifold
- Compute one contact point as approximation:
  - For circle-circle: contact = aPos + normal * (a.radius - penetration/2)
  - For polygon vs polygon: find deepest clipping region and choose mid-point of clipped edge (or use vertex-face contact).
- For more robust response add support for multiple contact points per pair (optional) but ensure deterministic ordering (sort contact points by coordinates).

#### 4) Resolution
- Two-stage approach (deterministic, game-feel focused):
  - Positional correction: apply minimal translation to separate overlapping objects proportionally to inverse mass (or equal if massless). Correction = normal * (penetration / (invMassA + invMassB)) * positionalCorrectionFactor.
  - Velocity impulse: compute relative velocity along normal, compute restitution (bounciness) and friction if desired, apply impulse = (-(1+e) * relVel) / (invMassSum) and apply to entity velocities.
- Triggers: if either collider.isTrigger true → do not resolve physically; emit overlap event instead and let Attack/Rule systems handle effects.
- Static vs dynamic:
  - Static entities (isStatic) have infinite mass (invMass = 0) and do not get moved; all correction applied to other entity.
- Mass and inertia:
  - Provide mass and optional rotation inertia fields on entities; default mass = 1.0. For polygon rotation support you must compute moment of inertia and rotate polygon vertices; otherwise constrain to translation-only physics.

Determinism:
- Use fixed restitution and friction coefficients defined per-collider or global defaults.
- Resolve contact pairs in deterministic order: sort contact pairs by (min(aId,bId), max(aId,bId)) before applying resolution.
- Use fixed small positionalCorrectionFactor (e.g., 0.2) to avoid tunneling, and consider Continuous Collision Detection for high-speed small objects if needed.

---

### Collision math essentials

- Projection of polygon on axis:
  - projMin = min(dot(vertex_i, axis))
  - projMax = max(dot(vertex_i, axis))
- Projection of circle on axis:
  - centerProj = dot(circleCenter, axis)
  - projMin = centerProj - radius
  - projMax = centerProj + radius
- Penetration = min(projMaxA - projMinB, projMaxB - projMinA) across all axes
- Normalization: axes must be normalized (unit). Keep deterministic normalization method.

Pseudocode: SAT narrowphase (polygon vs polygon)
1. axes = edgeNormals(A) + edgeNormals(B)
2. bestPenetration = +INF; bestNormal = null
3. For each axis in axes:
   - projA = projectPolygon(A, axis)
   - projB = projectPolygon(B, axis)
   - if (projA.max < projB.min || projB.max < projA.min) return NO_COLLISION
   - overlap = min(projA.max - projB.min, projB.max - projA.min)
   - if overlap < bestPenetration: bestPenetration = overlap; bestNormal = axis
4. contactNormal = ensurePointsFromAtoB(bestNormal, A, B)
5. return CONTACT(bestPenetration, contactNormal)

---

### Integration with EntityManager and modules

- Entity managers expose:
  - getEntity(id): IEntity
  - iterateEntities(fn)
  - registerEntity(e)
  - unregisterEntity(id)
- GameModelState contains a registry field (ModuleRegistry or EntityRegistry) with references to CharacterManager, ConsumableManager, ObjectManager, ProjectileManager.
- PhysicsModule should operate against combined set of active colliders, not per-manager. Use a central ColliderRegistry updated by EntityManagers when entities spawn/die or when collider params change.
- ColliderRegistry API:
  - addCollider(collider: Collider)
  - updateCollider(colliderId, transform)
  - removeCollider(colliderId)
  - listActiveColliders(): Array<Collider>

Entity lifecycle and physics flow per tick:
1. Engine invokes InputModule.applyInputs and AiModule.update which mutate entity intent fields (velocities, force requests).
2. PhysicsModule.integrate applies velocity * dt to entity.position (store previous position for CCD).
3. PhysicsModule updates ColliderRegistry transforms using new positions and rotations.
4. PhysicsModule runs broadphase -> narrowphase -> contact generation.
5. PhysicsModule resolves contacts and updates velocities/positions accordingly.
6. Post-resolution, PhysicsModule notifies other modules via EventBus: physics:contact, entity:blocked, entity:fall, etc.
7. Stores update cooldowns, collision-triggered effects run in RuleModule or AttackModule.

---

### Input buffer per player and server state buffer

#### Input buffer (per-player)
- Purpose: queue client inputs keyed by intendedServerTick so they can be applied deterministically on the correct tick.
- Data structure:
  - InputBuffer:
    - clientId: string
    - inputs: Array<InputEntry> sorted by intendedServerTick and sequence
  - InputEntry:
    - sequence: Int (monotonic client seq)
    - clientTick: Int
    - intendedServerTick: Int
    - payload: InputPayload
- API:
  - pushInput(clientId, input): append and maintain ordering
  - collectForTick(tick): return Array<InputPayload> where intendedServerTick == tick (remove those from buffer or mark consumed)
  - dropUpToSequence(clientId, seq): remove acknowledged inputs
- Determinism:
  - Use integer ticks; no wall-clock conversion in engine; client and server must agree on tick mapping via handshake.

#### Server state buffer (snapshot buffer)
- Purpose: store recent authoritative GameModelState snapshots for rollback and replay during reconciliation.
- Data structure:
  - SnapshotStore:
    - buffer: circular array of Snapshot objects (sorted by serverTick)
    - maxSize: Int
  - Snapshot:
    - serverTick: Int
    - serializedState: (deep deterministic copy of GameModelState)
    - optional meta: { rngState, eventLog }
- API:
  - storeSnapshot(snapshot)
  - loadSnapshot(tick): Snapshot | null
  - latestTick()
  - purgeBefore(tick)

Usage in reconciliation:
- On authoritative snapshot arrival, find anchorTick and loadSnapshot(anchorTick). If not present, fallback to earliest available snapshot and request a full state resync.
- Rollback: set engine.state = anchor.clone(); replay pending inputs in ascending intendedServerTick order applying modules stepFixed for each tick to reach current predicted tick.

Buffer sizing:
- Choose maxSize = expected max server-client latency in ticks + safety margin (e.g., tickRate * maxLagSeconds + 10).

---

### Examples and pseudocode

Create transient collider and resolve hits (simplified):
```pseudo
function spawnAttack(casterId, attackDef, startTick):
  collider = buildColliderFromAttack(attackDef)
  collider.ownerEntityId = casterId
  collider.durationTicks = attackDef.durationTicks
  addCollider(collider)
  transientColliders.push({ id:collider.id, expiresAt: startTick + collider.durationTicks })

PhysicsModule.stepCollision(state, tick):
  updateColliderTransforms(state)
  pairs = broadphase(colliders)
  pairs = filterByLayerMask(pairs)
  sortPairsDeterministic(pairs)
  contacts = []
  for p in pairs:
    c = narrowphase(p.a, p.b)
    if c:
      contacts.push(c)
  sortContactsDeterministic(contacts)
  for contact in contacts:
    if contact.involvesTrigger: emitEvent("physics:overlap", contact)
    else: resolveContact(contact)
  expireTransientColliders(tick)
```

Input application and tick loop snippet:
```pseudo
function stepFixed():
  nextTick = state.tick + 1
  inputs = inputBuffer.collectForTick(nextTick)
  applyInputs(inputs) // sets entity.vel or creates action intents
  ai.update(state, nextTick)
  physics.integrate(state, fixedDt)
  physics.stepCollision(state, nextTick)
  updateStores(state, fixedDt, nextTick)
  snapshotStore.storeSnapshot(state.clone())
  publishSnapshotIfNeeded()
  state.tick = nextTick
```

Rollback & replay:
```pseudo
function reconcile(authoritativeSnapshot):
  anchorTick = authoritativeSnapshot.serverTick
  anchor = snapshotStore.loadSnapshot(anchorTick)
  if not anchor: requestFullSync(); return
  pendingInputs = gatherPendingInputsSince(anchorTick)
  state = anchor.clone()
  for tick in anchorTick+1 .. authoritativeSnapshot.clientPredictedTick:
    inputs = pendingInputs.filter(intendedServerTick == tick)
    applyInputs(inputs)
    ai.update(state, tick)
    physics.integrate(state, fixedDt)
    physics.stepCollision(state, tick)
    updateStores(state, fixedDt, tick)
  replace engine.state with state
  compute and emit corrections
```

---

### Implementation considerations and best practices

- Use integer ticks as canonical time; fixedDt derived only for numeric integration calculations.
- Keep float epsilon constants and vector math functions identical across ports to reduce cross-platform divergence.
- For polygon math, precompute edge normals and bounding radius per collider to speed SAT.
- Deterministic ordering everywhere: pairs, contacts, entities, event emission; use stable sorting by id when needed.
- For high-speed projectiles consider discrete CCD: if displacement > radius in one step, subdivide integration or use raycast sweep against target colliders.
- Triggers vs physics bodies: keep trigger handling separate; triggers emit events but do not alter positions.
- Performance: tune spatial hash cell size, pool transient collider objects, batch contact resolution where possible.
- Debugging: expose debug hooks to dump active colliders, broadphase cell occupancy, contact lists and snapshot diffs.

---

If you want, I will:
- generate Haxe class skeletons for Collider types, ColliderRegistry, PhysicsModule (with SAT implementation stubs), SpatialHash, InputBuffer and SnapshotStore, or
- produce TypeScript versions and unit-test scaffolds for SAT narrowphase and rollback/replay.
