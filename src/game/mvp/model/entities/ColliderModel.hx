package game.mvp.model.entities;

import engine.model.entities.impl.EngineColliderEntity;
import engine.model.entities.base.BaseEngineEntity;

/**
 * Collider entity model extending BaseEntityModel
 * Wraps engine ColliderEntity with visual metadata
 */
class ColliderModel extends BaseEntityModel {
    // Reference to engine collider entity
    public var colliderEntity(get, never): EngineColliderEntity;
    
    public function new() {
        super();

        // Colliders are static, no position updates needed
        // Just ensure visual properties are set
        setVisualProperties();
    }
    
    private function get_colliderEntity(): EngineColliderEntity {
        return cast(engineEntity, EngineColliderEntity);
    }
    
    /**
     * Initialize with engine collider entity
     */
    override public function initialize(engineEntity: BaseEngineEntity): Void {
        super.initialize(engineEntity);
        
        // Colliders are static, no interpolation needed
        if (colliderEntity != null) {
            renderPos.x = colliderEntity.pos.x;
            renderPos.y = colliderEntity.pos.y;
            previousPos.x = colliderEntity.pos.x;
            previousPos.y = colliderEntity.pos.y;

            trace(colliderEntity.pos);
        }
    }
    
    /**
     * Update collider state from engine
     */
    override public function updateFromEngine(): Void {
        super.updateFromEngine();
        
        if (colliderEntity == null) return;
    }
    
    /**
     * Set visual properties based on collider type
     */
    override public function setVisualProperties(): Void {
        if (engineEntity == null) return;
        
        // Set red color for colliders
        color = 0xFF0000; // Red
        
        // Set visual scale
        visualScale = 1.0;
    }
    
    // Convenience getters that delegate to collider entity
    public var passable(get, never): Bool;
    public var isTrigger(get, never): Bool;
    
    private function get_passable(): Bool return colliderEntity != null ? colliderEntity.passable : false;
    private function get_isTrigger(): Bool return colliderEntity != null ? colliderEntity.isTrigger : false;
    
    /**
     * Reset for reuse
     */
    override public function reset(): Void {
        super.reset();
    }
}
