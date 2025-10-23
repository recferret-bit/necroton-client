package engine.presenter;

import engine.model.GameModelState;
import engine.modules.ModuleRegistry;
import engine.view.EventBusConstants;
import engine.view.IEventBus;

/**
 * Fixed timestep game loop
 */
class GameLoop {
    private var state: GameModelState;
    private var modules: ModuleRegistry;
    private var eventBus: IEventBus;
    private var running: Bool;
    private var fixedDt: Float;
    
    public function new(state: GameModelState, modules: ModuleRegistry, eventBus: IEventBus) {
        this.state = state;
        this.modules = modules;
        this.eventBus = eventBus;
        this.running = false;
        this.fixedDt = 1.0 / NecrotonEngine.Config.tickRate;
    }
    
    /**
     * Start the game loop
     */
    public function start(): Void {
        running = true;
    }
    
    /**
     * Stop the game loop
     */
    public function stop(): Void {
        running = false;
    }
    
    /**
     * Execute single fixed timestep
     */
    public function stepFixed(): Void {
        if (!running) return;
        
        // Increment tick
        state.tick++;
        final currentTick = state.tick;
        
        // Execute modules in deterministic order
        executeModules(currentTick, fixedDt);
        
        // Update entity managers
        state.managers.updateAll(fixedDt, currentTick, state);
        
        // Emit tick complete event
        eventBus.emit(EventBusConstants.TICK_COMPLETE, {tick: currentTick});
    }
    
    /**
     * Execute all modules in deterministic order
     * @param tick Current tick
     * @param dt Delta time
     */
    private function executeModules(tick: Int, dt: Float): Void {
        // 1. Input module - collect and apply inputs
        final inputModule = cast(modules.get("input"), engine.modules.InputModule);
        if (inputModule != null) {
            inputModule.update(state, tick, dt);
        }
        
        // 2. AI module - update AI behavior
        final aiModule = cast(modules.get("ai"), engine.modules.AIModule);
        if (aiModule != null) {
            aiModule.update(state, tick, dt);
        }
        
        // 3. Physics module - integrate and resolve collisions
        final physicsModule = cast(modules.get("physics"), engine.modules.PhysicsModule);
        if (physicsModule != null) {
            physicsModule.update(state, tick, dt);
        }
        
        // 4. Spawn module - cleanup dead entities
        final spawnModule = cast(modules.get("spawn"), engine.modules.SpawnModule);
        if (spawnModule != null) {
            spawnModule.update(state, tick, dt);
        }
    }
}
