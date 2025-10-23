package engine.model.managers;

import engine.model.EntityType;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.managers.IEngineEntityManager;

/**
 * Interface for entity manager registry
 * Provides type-safe access to entity managers
 */
interface IEngineEntityManagerRegistry {
    /**
     * Register a manager for a specific entity type
     * @param type Entity type
     * @param manager Manager instance
     */
    function register<T:BaseEngineEntity>(type: EntityType, manager: IEngineEntityManager<T>): Void;
    
    /**
     * Get manager by entity type
     * @param type Entity type
     * @return Manager or null
     */
    function get<T:BaseEngineEntity>(type: EntityType): IEngineEntityManager<T>;
    
    /**
     * Get all managers
     * @return Array of managers
     */
    function getAll(): Array<IEngineEntityManager<BaseEngineEntity>>;
    
    /**
     * Update all managers for this tick
     * @param dt Delta time
     * @param tick Current tick
     * @param state Game state
     */
    function updateAll(dt: Float, tick: Int, state: Dynamic): Void;
    
    /**
     * Save all managers as memento
     * @return Array of manager mementos
     */
    function saveMemento(): Array<GameModelState.EntityManagerMemento>;
    
    /**
     * Restore managers from memento
     * @param mementos Array of manager mementos
     */
    function restoreMemento(mementos: Array<GameModelState.EntityManagerMemento>): Void;
    
    /**
     * Clear all managers
     */
    function clear(): Void;
}
