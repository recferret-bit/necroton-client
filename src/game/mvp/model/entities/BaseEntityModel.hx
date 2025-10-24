package game.mvp.model.entities;

import engine.model.entities.EntityType;
import engine.model.entities.base.BaseEngineEntity;

/**
 * Base entity model that wraps engine BaseEntity
 * Adds visual metadata and game-specific properties
 */
class BaseEntityModel {
    // Reference to engine entity (no duplication!)
    public var engineEntity: BaseEngineEntity;
    
    // Visual properties
    public var color: Int;
    public var visualScale: Float;
    
    // Interpolation support
    public var previousPos: engine.geometry.Vec2;
    public var renderPos: engine.geometry.Vec2;
    public var positionHistory: Array<{tick: Int, pos: engine.geometry.Vec2}>;
    public var interpolationAlpha: Float;
    
    // Sync state
    public var needsVisualUpdate: Bool;
    public var lastUpdateTick: Int;
    
    public function new() {
        color = 0xFFFFFF;
        visualScale = 1.0;
        
        // Initialize interpolation fields
        previousPos = engine.geometry.Vec2Utils.create(0, 0);
        renderPos = engine.geometry.Vec2Utils.create(0, 0);
        positionHistory = [];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    /**
     * Initialize with engine entity
     */
    public function initialize(engineEntity: BaseEngineEntity): Void {
        this.engineEntity = engineEntity;
        setVisualProperties();
        
        // Initialize interpolation with current position
        previousPos = engine.geometry.Vec2Utils.create(engineEntity.pos.x, engineEntity.pos.y);
        renderPos = engine.geometry.Vec2Utils.create(engineEntity.pos.x, engineEntity.pos.y);
        positionHistory = [{tick: 0, pos: engine.geometry.Vec2Utils.create(engineEntity.pos.x, engineEntity.pos.y)}];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    /**
     * Update from engine entity (called each frame)
     */
    public function updateFromEngine(): Void {
        if (engineEntity == null) return;
        
        needsVisualUpdate = true;
        lastUpdateTick++;
    }
    
    /**
     * Set visual properties based on entity type
     */
    public function setVisualProperties(): Void {
        if (engineEntity == null) return;
        
        switch (engineEntity.type) {
            case CHARACTER:
                color = 0x00FF00;  // Green
            case CONSUMABLE:
                color = 0xFFFF00;  // Yellow
            case EFFECT:
                color = 0xFF00FF;  // Magenta
            default:
                color = 0xFFFFFF;  // White
        }
    }
    
    /**
     * Reset for reuse in object pool
     */
    public function reset(): Void {
        engineEntity = null;
        color = 0xFFFFFF;
        visualScale = 1.0;
        
        // Reset interpolation fields
        previousPos = engine.geometry.Vec2Utils.create(0, 0);
        renderPos = engine.geometry.Vec2Utils.create(0, 0);
        positionHistory = [];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    // Convenience getters that delegate to engine entity
    public var id(get, never): Int;
    public var type(get, never): EntityType;
    public var pos(get, never): engine.geometry.Vec2;
    public var vel(get, never): engine.geometry.Vec2;
    public var rotation(get, never): Float;
    public var ownerId(get, never): String;
    public var isAlive(get, never): Bool;
    public var colliderWidth(get, never): Float;
    public var colliderHeight(get, never): Float;
    
    private function get_id(): Int return engineEntity != null ? engineEntity.id : 0;
    private function get_type(): EntityType return engineEntity != null ? engineEntity.type : CHARACTER;
    private function get_pos(): engine.geometry.Vec2 return engineEntity != null ? engineEntity.pos : engine.geometry.Vec2Utils.create(0, 0);
    private function get_vel(): engine.geometry.Vec2 return engineEntity != null ? engineEntity.vel : engine.geometry.Vec2Utils.create(0, 0);
    private function get_rotation(): Float return engineEntity != null ? engineEntity.rotation : 0;
    private function get_ownerId(): String return engineEntity != null ? engineEntity.ownerId : "";
    private function get_isAlive(): Bool return engineEntity != null ? engineEntity.isAlive : false;
    private function get_colliderWidth(): Float return engineEntity != null ? engineEntity.colliderWidth : 1.0;
    private function get_colliderHeight(): Float return engineEntity != null ? engineEntity.colliderHeight : 1.0;
}
