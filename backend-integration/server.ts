/**
 * Node.js backend server with NecrotonEngine integration
 * Runs at 20 TPS using setImmediate for non-blocking execution
 */

import { 
  engine,
  NecrotonEngine,
  EngineConfig, 
  EntityType, 
  EngineEntitySpec, 
  InputMessage,
  EventBusConstants,
  EntitySpawnEvent, 
  EntityMoveEvent, 
  EntityDeathEvent, 
  EntityDamageEvent,
  EntityCollisionEvent,
  EntityCorrectionEvent,
  TickCompleteEvent,
  SnapshotEvent,
  ColliderTriggerEvent,
  PhysicsContactEvent
} from './engine';

class GameServer {
  private engine: NecrotonEngine;
  private isRunning: boolean = false;
  private lastTickTime: number = 0;
  private tickInterval: number = 1000 / 20; // 20 TPS = 50ms per tick
  private gameLoopTimer: NodeJS.Immediate | null = null;

  constructor() {
    // Initialize engine with server configuration
    const config: EngineConfig = {
      mode: "SERVER" as any, // Use string literal for Haxe enum
      tickRate: 20,
      unitPixels: 32,
      aiUpdateInterval: 10,
      snapshotBufferSize: 1000,
      rngSeed: 12345,
      snapshotEmissionInterval: 5
    };

    this.engine = engine.NecrotonEngine.create(config);
    this.setupEventHandlers();
  }

  /**
   * Setup event handlers for all engine events
   */
  private setupEventHandlers(): void {
    // Entity events
    this.engine.subscribeEvent<EntitySpawnEvent>("entity:spawn", (event) => {
      console.log(`[${event.tick}] Entity spawned: ID=${event.entityId}, Type=${event.type}, Pos=(${event.pos.x}, ${event.pos.y}), Owner=${event.ownerId}`);
    });

    this.engine.subscribeEvent<EntityMoveEvent>("entity:move", (event) => {
      console.log(`[${event.tick}] Entity moved: ID=${event.entityId}, Pos=(${event.pos.x}, ${event.pos.y}), Vel=(${event.vel.x}, ${event.vel.y})`);
    });

    this.engine.subscribeEvent<EntityDeathEvent>("entity:death", (event) => {
      console.log(`[${event.tick}] Entity died: ID=${event.entityId}, Killer=${event.killerId}`);
    });

    this.engine.subscribeEvent<EntityDamageEvent>("entity:damage", (event) => {
      console.log(`[${event.tick}] Entity damaged: ID=${event.entityId}, Damage=${event.damage}, NewHP=${event.newHp}, Attacker=${event.attackerId}`);
    });

    this.engine.subscribeEvent<EntityCollisionEvent>("entity:collision", (event) => {
      console.log(`[${event.tick}] Entity collision: ${event.entityIdA} vs ${event.entityIdB}, Contact=(${event.contactPoint.x}, ${event.contactPoint.y})`);
    });

    this.engine.subscribeEvent<EntityCorrectionEvent>("entity:correction", (event) => {
      console.log(`[${event.tick}] Entity correction: ID=${event.entityId}, NewPos=(${event.correctedPos.x}, ${event.correctedPos.y})`);
    });

    // Tick events
    this.engine.subscribeEvent<TickCompleteEvent>("tick:complete", (event) => {
      console.log(`[${event.tick}] Tick completed`);
    });

    // Snapshot events
    this.engine.subscribeEvent<SnapshotEvent>("snapshot", (event) => {
      console.log(`[${event.tick}] Snapshot emitted`);
    });

    // Collider events
    this.engine.subscribeEvent<ColliderTriggerEvent>("collider:trigger", (event) => {
      console.log(`[${event.tick}] Collider triggered: Entity=${event.entityId}, Collider=${event.colliderId}, Pos=(${event.triggerPos.x}, ${event.triggerPos.y})`);
    });

    // Physics events
    this.engine.subscribeEvent<PhysicsContactEvent>("physics:contact", (event) => {
      console.log(`[${event.tick}] Physics contact: ${event.entityIdA} vs ${event.entityIdB}, Impulse=${event.impulse}`);
    });
  }

  /**
   * Start the game server
   */
  public start(): void {
    console.log('Starting NecrotonEngine backend server...');
    console.log('Configuration: 20 TPS, SERVER mode');
    
    this.engine.start();
    this.isRunning = true;
    this.lastTickTime = Date.now();
    
    // Start the game loop
    this.gameLoop();
    
    // Spawn some example entities
    this.spawnExampleEntities();
    
    console.log('Game server started successfully!');
  }

  /**
   * Stop the game server
   */
  public stop(): void {
    console.log('Stopping game server...');
    this.isRunning = false;
    
    if (this.gameLoopTimer) {
      clearImmediate(this.gameLoopTimer);
      this.gameLoopTimer = null;
    }
    
    this.engine.stop();
    console.log('Game server stopped.');
  }

  /**
   * Game loop using setImmediate for non-blocking 20 TPS execution
   */
  private gameLoop(): void {
    if (!this.isRunning) return;

    const now = Date.now();
    const deltaTime = now - this.lastTickTime;
    
    // Only step if enough time has passed (20 TPS = 50ms per tick)
    if (deltaTime >= this.tickInterval) {
      this.engine.stepFixed();
      this.lastTickTime = now;
    }
    
    // Schedule next iteration
    this.gameLoopTimer = setImmediate(() => this.gameLoop());
  }

  /**
   * Spawn example entities to demonstrate functionality
   */
  private spawnExampleEntities(): void {
    console.log('Spawning example entities...');
    
    // Spawn a character
    const characterSpec: EngineEntitySpec = {
      type: "character" as any, // Use string literal for Haxe enum
      pos: { x: 100, y: 100 },
      vel: { x: 0, y: 0 },
      rotation: 0,
      ownerId: "server",
      isAlive: true,
      isInputDriven: false,
      maxHp: 100,
      hp: 100,
      level: 1,
      stats: {
        power: 10,
        armor: 5,
        speed: 1,
        castSpeed: 1
      }
    };
    
    const characterId = this.engine.spawnEntity(characterSpec);
    console.log(`Spawned character with ID: ${characterId}`);
    
    // Spawn a collider
    const colliderSpec: EngineEntitySpec = {
      type: "collider" as any, // Use string literal for Haxe enum
      pos: { x: 200, y: 200 },
      vel: { x: 0, y: 0 },
      rotation: 0,
      ownerId: "server",
      isAlive: true,
      colliderWidth: 50,
      colliderHeight: 50,
      passable: false,
      isTrigger: false
    };
    
    const colliderId = this.engine.spawnEntity(colliderSpec);
    console.log(`Spawned collider with ID: ${colliderId}`);
    
    // Spawn a consumable (commented out due to Haxe spec requirements)
    // const consumableSpec: EngineEntitySpec = {
    //   type: "consumable" as any, // Use string literal for Haxe enum
    //   pos: { x: 300, y: 300 },
    //   vel: { x: 0, y: 0 },
    //   rotation: 0,
    //   ownerId: "server",
    //   isAlive: true,
    //   effectId: "health_potion",
    //   durationTicks: 0,
    //   stackable: true,
    //   charges: 1,
    //   useRange: 50,
    //   consumableType: "potion",
    //   quantity: 1,
    //   effectValue: 50
    // };
    
    // const consumableId = this.engine.spawnEntity(consumableSpec);
    // console.log(`Spawned consumable with ID: ${consumableId}`);
  }

  /**
   * Queue input from a client
   */
  public queueClientInput(clientId: string, sequence: number, movement: {x: number, y: number}, actions: any[] = []): void {
    const input: InputMessage = {
      clientId,
      sequence,
      clientTick: this.engine.getCurrentTick(),
      intendedServerTick: this.engine.getCurrentTick(),
      movement,
      actions,
      timestamp: Date.now()
    };
    
    this.engine.queueInput(input);
  }

  /**
   * Get current game state
   */
  public getGameState(): any {
    return this.engine.getSnapshot();
  }

  /**
   * Get current tick
   */
  public getCurrentTick(): number {
    return this.engine.getCurrentTick();
  }
}

// Create and start the server
const gameServer = new GameServer();

// Graceful shutdown handling
process.on('SIGINT', () => {
  console.log('\nReceived SIGINT, shutting down gracefully...');
  gameServer.stop();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\nReceived SIGTERM, shutting down gracefully...');
  gameServer.stop();
  process.exit(0);
});

// Start the server
gameServer.start();

// Example: Simulate some client input after 5 seconds
setTimeout(() => {
  console.log('\nSimulating client input...');
  gameServer.queueClientInput("player1", 1, { x: 1, y: 0 }, []);
  gameServer.queueClientInput("player1", 2, { x: 0, y: 1 }, []);
}, 5000);

// Example: Show game state after 10 seconds
setTimeout(() => {
  console.log('\nCurrent game state:');
  console.log(`Tick: ${gameServer.getCurrentTick()}`);
  console.log('Game state snapshot available via getGameState()');
}, 10000);
