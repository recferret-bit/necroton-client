package engine.modules;

import engine.model.GameModelState;

/**
 * Module contract for engine modules
 */
interface IModule {
    /**
     * Update module for this tick
     * @param state Game state
     * @param tick Current tick
     * @param dt Delta time
     */
    function update(state: GameModelState, tick: Int, dt: Float): Void;
    
    /**
     * Shutdown module
     */
    function shutdown(): Void;
}
