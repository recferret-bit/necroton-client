package engine.modules;

import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Spawn module for entity lifecycle
 */
class SpawnModule implements IModule {

    public function new() {
    }
    
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Clean up dead entities
        cleanupDeadEntities(state);
    }
    
    public function shutdown(): Void {
    }
    
    /**
     * Spawn entity
     * @param spec Entity specification
     * @return Created entity
     */
    public function spawn(spec: EngineEntitySpec): BaseEngineEntity {
        // This would be called by the main engine
        // Implementation would depend on the specific entity type
        return null;
    }
    
    /**
     * Despawn entity
     * @param entityId Entity ID
     */
    public function despawn(entityId: Int): Void {
        // This would be called by the main engine
        // Implementation would find and remove entity from appropriate manager
    }
    
    private function cleanupDeadEntities(state: GameModelState): Void {
        // Remove dead entities from all managers
        for (manager in state.managers.getAll()) {
            final toRemove = [];
            manager.iterate(function(entity) {
                if (!entity.isAlive) {
                    toRemove.push(entity.id);
                }
            });
            
            for (id in toRemove) {
                manager.destroy(id);
            }
        }
    }
}
