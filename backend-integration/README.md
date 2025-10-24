# NecrotonEngine Backend Integration

This folder contains TypeScript bindings and a Node.js backend server example for the NecrotonEngine.

## Overview

The backend integration provides:
- Clean TypeScript type definitions for the compiled Haxe engine
- Event bus constants and types for type-safe event handling
- A Node.js server example running at 20 TPS using `setImmediate`
- Complete event logging and entity management examples

## Files

- `engine.js` - Compiled Haxe engine (copied from `dist/engine.js`)
- `engine.d.ts` - Complete TypeScript definitions including engine API, event constants, and event types
- `server.ts` - Node.js backend server example
- `package.json` - Backend dependencies and scripts
- `tsconfig.json` - TypeScript configuration

## Setup

1. Install dependencies:
```bash
npm install
```

2. Compile TypeScript:
```bash
npm run build
```

3. Run the server:
```bash
npm start
```

## Usage

### Basic Engine Setup

```typescript
import { NecrotonEngine, EngineConfig, EngineMode } from './engine';

const config: EngineConfig = {
  mode: EngineMode.SERVER,
  tickRate: 20,
  unitPixels: 32,
  aiUpdateInterval: 10,
  snapshotBufferSize: 1000,
  rngSeed: 12345,
  snapshotEmissionInterval: 5
};

const engine = NecrotonEngine.create(config);
engine.start();
```

### Event Handling

```typescript
import { EventBusConstants, EntitySpawnEvent } from './engine';

// Subscribe to entity spawn events
engine.subscribeEvent<EntitySpawnEvent>(EventBusConstants.ENTITY_SPAWN, (event) => {
  console.log(`Entity spawned: ${event.entityId} at (${event.pos.x}, ${event.pos.y})`);
});
```

### Entity Spawning

```typescript
import { EntityType, EngineEntitySpec } from './engine';

const characterSpec: EngineEntitySpec = {
  type: EntityType.CHARACTER,
  pos: { x: 100, y: 100 },
  ownerId: "player1",
  maxHp: 100,
  hp: 100,
  level: 1
};

const entityId = engine.spawnEntity(characterSpec);
```

### Input Handling

```typescript
import { InputMessage } from './engine';

const input: InputMessage = {
  clientId: "player1",
  sequence: 1,
  clientTick: engine.getCurrentTick(),
  intendedServerTick: engine.getCurrentTick(),
  movement: { x: 1, y: 0 },
  actions: [],
  timestamp: Date.now()
};

engine.queueInput(input);
```

## Server Example

The `server.ts` file demonstrates:
- Engine initialization with SERVER mode at 20 TPS
- Non-blocking game loop using `setImmediate`
- Complete event subscription and logging
- Example entity spawning (character, collider, consumable)
- Client input simulation
- Graceful shutdown handling

## Event Types

The engine emits the following events:

### Entity Events
- `ENTITY_SPAWN` - When an entity is created
- `ENTITY_DEATH` - When an entity is destroyed
- `ENTITY_MOVE` - When an entity moves
- `ENTITY_DAMAGE` - When an entity takes damage
- `ENTITY_COLLISION` - When entities collide
- `ENTITY_CORRECTION` - When entity position is corrected

### System Events
- `TICK_COMPLETE` - When a simulation tick completes
- `SNAPSHOT` - When a game state snapshot is emitted
- `PHYSICS_CONTACT` - When physics contacts occur
- `COLLIDER_TRIGGER` - When collider triggers activate

### Action Events
- `ACTION_INTENT` - When an action is initiated
- `ACTION_RESOLVED` - When an action is completed

## Configuration

The engine supports three modes:
- `SINGLEPLAYER` - Single player mode
- `SERVER` - Server mode (emits snapshots)
- `CLIENT_PREDICTION` - Client prediction mode

## Performance

The server runs at 20 TPS (50ms per tick) using `setImmediate` for non-blocking execution. This provides:
- Consistent simulation timing
- Non-blocking I/O operations
- Efficient event processing
- Scalable architecture

## Development

- `npm run build` - Compile TypeScript
- `npm run dev` - Build and run
- `npm run watch` - Watch mode for development

## Integration Notes

- The engine.js file is the compiled Haxe output
- Type definitions are manually created for clean TypeScript integration
- Event constants and types are exported for easy use
- The server example shows best practices for backend integration
