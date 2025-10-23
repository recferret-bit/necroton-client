package engine;

import engine.EngineConfig;
import engine.model.EntityType;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;
import engine.model.entities.impl.EngineCharacterEntity;
import engine.model.entities.impl.EngineColliderEntity;
import engine.model.managers.IEngineEntityManager;
import engine.modules.AIModule;
import engine.modules.InputModule;
import engine.modules.ModuleRegistry;
import engine.modules.PhysicsModule;
import engine.modules.SpawnModule;
import engine.presenter.GameLoop;
import engine.presenter.InputMessage;
import engine.presenter.SnapshotManager;
import engine.view.EventBus;
import engine.view.EventBusConstants;
import engine.view.IEventBus;

/**
 * Main Necroton Engine - portable game engine with MVP architecture
 * 
 * Usage:
 * ```haxe
 * var config = {
 *   mode: SINGLEPLAYER,
 *   tickRate: 60,
 *   entitySizePixels: 32,
 *   aiUpdateInterval: 10,
 *   snapshotBufferSize: 1000,
 *   spatialHashCellSize: 64,
 *   rngSeed: 12345,
 *   snapshotEmissionInterval: 5
 * };
 * 
 * var engine = NecrotonEngine.create(config);
 * engine.start();
 * 
 * // Subscribe to events
 * var token = engine.subscribeEvent(EventBusConstants.ENTITY_SPAWN, function(event) {
 *   trace("Entity spawned: " + event.entityId);
 * });
 * 
 * // Spawn entities
 * var entityId = engine.spawnEntity(EntityType.CHARACTER, {
 *   pos: {x: 100, y: 200},
 *   ownerId: "player1",
 *   params: {level: 1, maxHp: 100}
 * });
 * 
 * // Queue inputs
 * engine.queueInput({
 *   clientId: "player1",
 *   sequence: 1,
 *   clientTick: 1,
 *   intendedServerTick: 1,
 *   movement: {x: 1, y: 0},
 *   actions: []
 * });
 * ```
 */
class NecrotonEngine {
    public static var Config: EngineConfig;
    
    private var config: EngineConfig;
    private var state: GameModelState;
    private var modules: ModuleRegistry;
    private var eventBus: IEventBus;
    private var gameLoop: GameLoop;
    private var snapshotManager: SnapshotManager;
    private var running: Bool;
    
    private function new(config: EngineConfig) {
        Config = config;

        this.state = new GameModelState(Config.rngSeed);
        this.modules = new ModuleRegistry();
        this.eventBus = new EventBus();
        this.snapshotManager = new SnapshotManager(Config.snapshotBufferSize);
        this.running = false;
        
        setupModules();
        this.gameLoop = new GameLoop(state, modules, eventBus);
    }
    
    /**
     * Create new engine instance
     * @param config Engine configuration
     * @return Engine instance
     */
    public static function create(config: EngineConfig): NecrotonEngine {
        return new NecrotonEngine(config);
    }
    
    /**
     * Main function for compilation
     */
    public static function main(): Void {
        // This is just for compilation - the engine is used as a library
        trace("Necroton Engine compiled successfully");
    }
    
    /**
     * Start the engine
     */
    public function start(): Void {
        running = true;
        gameLoop.start();
    }
    
    /**
     * Stop the engine
     */
    public function stop(): Void {
        running = false;
        gameLoop.stop();
    }
    
    /**
     * Stop simulation (alias for stop)
     */
    public function stopSimulation(): Void {
        stop();
    }
    
    /**
     * Step engine simulation
     * @param dt Delta time
     */
    public function step(dt: Float): Void {
        stepFixed();
    }
    
    /**
     * Queue input from client
     * @param input Input message
     */
    public function queueInput(input: InputMessage): Void {
        final inputModule = cast(modules.get("input"), InputModule);
        if (inputModule != null) {
            inputModule.queueInput(input);
        }
    }
    
    /**
     * Spawn entity
     * @param type Entity type
     * @param spec Entity specification
     * @return Entity ID
     */
    public function spawnEntity(spec: EngineEntitySpec): Int {
        final entityId = state.allocateEntityId();
        spec.id = entityId;
        
        // Find appropriate manager
        final manager: IEngineEntityManager<BaseEngineEntity> = state.managers.get(spec.type);
        if (manager != null) {
            final entity = manager.create(spec);
            
            // Emit spawn event
            eventBus.emit(EventBusConstants.ENTITY_SPAWN, {
                tick: state.tick,
                entityId: entity.id,
                type: entity.type,
                pos: entity.pos,
                ownerId: entity.ownerId
            });
            
            return entity.id;
        }
        
        return 0;
    }
    
    /**
     * Despawn entity
     * @param entityId Entity ID
     */
    public function despawnEntity(entityId: Int): Void {
        // Find entity in managers
        for (manager in state.managers.getAll()) {
            final entity = manager.find(entityId);
            if (entity != null) {
                // Emit death event
                eventBus.emit(EventBusConstants.ENTITY_DEATH, {
                    tick: state.tick,
                    entityId: entityId,
                    killerId: 0
                });
                
                manager.destroy(entityId);
                break;
            }
        }
    }
    
    /**
     * Subscribe to events with typed handler
     * @param topic Event topic
     * @param handler Event handler
     * @return Subscription token
     */
    public function subscribeEvent<T>(topic: String, handler: T->Void): Int {
        return eventBus.subscribe(topic, handler);
    }
    
    /**
     * Subscribe to events with dynamic handler (legacy support)
     * @param topic Event topic
     * @param handler Event handler
     * @return Subscription token
     */
    public function subscribeEventDynamic(topic: String, handler: Dynamic->Void): Int {
        return eventBus.subscribeDynamic(topic, handler);
    }
    
    /**
     * Unsubscribe from events
     * @param token Subscription token
     */
    public function unsubscribeEvent(token: Int): Void {
        eventBus.unsubscribe(token);
    }
    
    /**
     * Get current snapshot
     * @return State memento
     */
    public function getSnapshot(): GameStateMemento {
        return state.saveMemento();
    }
    
    /**
     * Get event bus for subscribing to events
     * @return Event bus instance
     */
    public function getEventBus(): IEventBus {
        return eventBus;
    }
    
    /**
     * Get input module
     * @return Input module instance
     */
    public function getInputModule(): InputModule {
        return cast(modules.get("input"), InputModule);
    }
    
    /**
     * Get character by ID
     * @return Character entity id
     */
    public function getCharacterById(id: Int): EngineCharacterEntity {
        final manager: IEngineEntityManager<EngineCharacterEntity> = state.managers.get(EntityType.CHARACTER);
        return manager.find(id);
    }
    
    /**
     * Get collider by ID
     * @param id Collider ID
     * @return Entity manager
     */
    public function getColliderById(id: Int): EngineColliderEntity {
        final manager: IEngineEntityManager<EngineColliderEntity> = state.managers.get(EntityType.COLLIDER);
        return manager.find(id);
    }
    
    /**
     * Get current engine tick
     * @return Current tick
     */
    public function getCurrentTick(): Int {
        return state.tick;
    }

    /**
     * Get all entities from all managers
     * @return Array of all entities
     */
    private function getAllEntities(): Array<Dynamic> {
        final entities = [];
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                entities.push(entity);
            });
        }
        return entities;
    }
    
    /**
     * Rollback and replay for client prediction
     * @param anchorTick Anchor tick for rollback
     * @param pendingInputs Pending inputs to replay
     */
    public function rollbackAndReplay(anchorTick: Int, pendingInputs: Array<InputMessage>): Void {
        // Load anchor state
        final anchorMemento = snapshotManager.load(anchorTick);
        if (anchorMemento == null) {
            trace("Warning: No snapshot found for anchor tick " + anchorTick);
            return;
        }
        
        // Rollback to anchor state
        state.restoreMemento(anchorMemento);
        
        // Replay pending inputs
        for (input in pendingInputs) {
            if (input.intendedServerTick > anchorTick) {
                queueInput(input);
            }
        }
        
        // Step forward to current tick
        final currentTick = state.tick;
        while (state.tick < currentTick) {
            gameLoop.stepFixed();
        }
        
        // Emit correction events
        emitCorrectionEvents();
    }
    
    /**
     * Execute single engine step
     */
    public function stepFixed(): Void {
        gameLoop.stepFixed();
        
        // Store snapshot
        snapshotManager.store(state.tick, state.saveMemento());
        
        // Emit snapshot events based on mode
        emitSnapshotEvents();
    }
    
    private function setupModules(): Void {
        // Create and register modules
        final inputModule = new InputModule();
        final physicsModule = new PhysicsModule();
        final aiModule = new AIModule();
        final spawnModule = new SpawnModule();
        
        modules.register("input", inputModule);
        modules.register("physics", physicsModule);
        modules.register("ai", aiModule);
        modules.register("spawn", spawnModule);
    }

    private function emitSnapshotEvents(): Void {
        switch (NecrotonEngine.Config.mode) {
            case SINGLEPLAYER:
                // No snapshot events for singleplayer
            case SERVER:
                if (state.tick % NecrotonEngine.Config.snapshotEmissionInterval == 0) {
                    eventBus.emit(EventBusConstants.SNAPSHOT, {
                        tick: state.tick,
                        serializedState: state.saveMemento()
                    });
                }
            case CLIENT_PREDICTION:
                // Always emit snapshots for client prediction
                eventBus.emit(EventBusConstants.SNAPSHOT, {
                    tick: state.tick,
                    serializedState: state.saveMemento()
                });
        }
    }
    
    private function emitCorrectionEvents(): Void {
        // Emit entity correction events for client prediction
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                eventBus.emit(EventBusConstants.ENTITY_CORRECTION, {
                    tick: state.tick,
                    entityId: entity.id,
                    correctedPos: entity.pos,
                    correctedVel: entity.vel
                });
            });
        }
    }
}
