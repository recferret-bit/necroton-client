# Necroton Engine

A portable, deterministic game engine following MVP (Model-View-Presenter) architecture. Designed for backend simulation and client-side prediction in multiplayer games.

## Features

- **Three Operational Modes**: Singleplayer, Server, Client Prediction
- **Deterministic Simulation**: Fixed timestep with seeded RNG
- **Event-Driven Architecture**: Clean separation between simulation and rendering
- **Entity Management**: Factory pattern with object pooling
- **Rollback Support**: Full rollback-replay for client prediction
- **Modular Design**: Pluggable modules for AI, Physics, Input, etc.

## Architecture

### Model Layer
- `GameModelState`: Central game state container
- `IEntity`: Entity contract with clone/serialize/reset
- `EntityFactory`: Factory pattern with registration
- `ObjectPool`: Entity reuse for performance
- `DeterministicRng`: Seeded random number generator

### View Layer
- `IEventBus`: Event publishing/subscribing
- `EventTypes`: Event schemas for all state changes
- Individual events: `entity:spawn`, `entity:move`, `entity:damage`, etc.

### Presenter Layer
- `NecrotonEngine`: Main orchestrator and public API
- `GameLoop`: Fixed timestep execution
- `SnapshotManager`: Circular buffer for rollback
- `InputBuffer`: Per-client input queuing

### Modules
- `InputModule`: Input collection and application
- `PhysicsModule`: Movement integration and collision
- `AIModule`: Entity behavior (extensible)
- `SpawnModule`: Entity lifecycle management

## Usage

### Basic Setup

```haxe
// Create configuration
var config = {
    mode: SINGLEPLAYER,
    tickRate: 60,
    entitySizePixels: 32,
    aiUpdateInterval: 10,
    snapshotBufferSize: 1000,
    spatialHashCellSize: 64,
    rngSeed: 12345,
    snapshotEmissionInterval: 5
};

// Create engine
var engine = NecrotonEngine.create(config);
engine.start();
```

### Entity Management

```haxe
// Spawn entities
var characterId = engine.spawnEntity("character", {
    pos: {x: 100, y: 200},
    ownerId: "player1",
    params: {level: 1, maxHp: 100, stats: {power: 10}}
});

var consumableId = engine.spawnEntity("consumable", {
    pos: {x: 150, y: 250},
    ownerId: "",
    params: {effectId: "heal", durationTicks: 300}
});

// Despawn entities
engine.despawnEntity(characterId);
```

### Input Handling

```haxe
// Queue player input
engine.queueInput({
    clientId: "player1",
    sequence: 1,
    clientTick: 1,
    intendedServerTick: 1,
    movement: {x: 1, y: 0},
    actions: [{type: "attack", target: 123}]
});
```

### Event Subscription

```haxe
// Subscribe to events
var spawnToken = engine.subscribeEvent(EventBusConstants.ENTITY_SPAWN, function(event) {
    trace("Entity spawned: " + event.entityId);
});

var moveToken = engine.subscribeEvent(EventBusConstants.ENTITY_MOVE, function(event) {
    // Update rendering
    updateEntityPosition(event.entityId, event.pos);
});

// Unsubscribe
engine.unsubscribeEvent(spawnToken);
```

### Rollback (Client Prediction)

```haxe
// Rollback to anchor tick and replay inputs
engine.rollbackAndReplay(anchorTick, pendingInputs);

// Engine will emit entity:correction events for smooth interpolation
```

## Engine Modes

### SINGLEPLAYER
- No input buffering
- No snapshot events emitted
- Full entity events for rendering

### SERVER
- Buffer inputs by intendedServerTick
- Emit snapshot events periodically
- Full entity events for network clients

### CLIENT_PREDICTION
- Buffer inputs by intendedServerTick
- Store snapshots every tick
- Rollback on authoritative snapshot
- Emit correction events after reconciliation

## Event Types

- `entity:spawn` - Entity created
- `entity:move` - Position/velocity changed
- `entity:damage` - Entity took damage
- `entity:death` - Entity destroyed
- `entity:collision` - Collision detected
- `action:intent` - Action initiated
- `action:resolved` - Action completed
- `tick:complete` - Simulation tick finished
- `snapshot` - State snapshot (SERVER/CLIENT_PREDICTION modes)
- `entity:correction` - Position correction (CLIENT_PREDICTION mode)

## Compilation

The engine compiles to a single JavaScript file:

```bash
haxe compile-backend.hxml
```

Output: `dist/engine.js`

## Integration

### Backend (Node.js)
```javascript
const engine = require('./dist/engine.js');
const config = {
    mode: engine.engine_EngineMode.SERVER,
    tickRate: 60,
    // ... other config
};
const gameEngine = engine.engine_NecrotonEngine.create(config);
```

### Frontend (Browser)
```html
<script src="dist/engine.js"></script>
<script>
    const engine = engine_NecrotonEngine.create(config);
    engine.start();
</script>
```

## Extensibility

### Custom Entity Types
```haxe
// Register custom entity factory
entityFactory.register("projectile", function() return new ProjectileEntity());
```

### Custom AI Behaviors
```haxe
// Register AI profile
aiModule.registerProfile("aggressive", {
    attackRange: 100,
    chaseDistance: 200,
    behavior: "aggressive"
});
```

### Custom Modules
```haxe
class CustomModule implements IModule {
    public function init(registry, state, config) { }
    public function update(state, tick, dt) { }
    public function shutdown() { }
}
```

## Performance Considerations

- Object pooling for entities
- Spatial hash for collision detection
- Deterministic iteration order
- Minimal allocations in hot paths
- Configurable snapshot buffer size

## Testing

The engine is designed for deterministic testing:

```haxe
// Same seed + same inputs = same results
var engine1 = NecrotonEngine.create({rngSeed: 12345, ...});
var engine2 = NecrotonEngine.create({rngSeed: 12345, ...});

// Apply same inputs to both
// Results will be identical
```

## License

This engine is part of the Necroton project and follows the project's licensing terms.
