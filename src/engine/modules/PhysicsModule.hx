package engine.modules;

import engine.geometry.Rect;
import engine.geometry.RectUtils;
import engine.geometry.Vec2Utils;
import engine.model.entities.EntityType;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.impl.EngineColliderEntity;
import engine.NecrotonEngine;

/**
 * Physics module for movement and collision
 */
class PhysicsModule implements IModule {
    
    public function new() {
    }
    
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Integrate velocities into positions
        integrate(state, dt);
        
        // Run collision detection and resolution
        stepCollision(state, tick);
    }
    
    public function shutdown(): Void {
    }
    
    /**
     * Integrate velocities into positions
     * @param state Game state
     * @param dt Delta time
     */
    public function integrate(state: GameModelState, dt: Float): Void {
        // Update all entities in all managers
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive) {
                    // Skip velocity integration for input-driven entities
                    // (movement is already applied in InputModule)
                    if (!entity.isInputDriven) {
                        // Apply velocity to position for physics-driven entities
                        entity.pos = Vec2Utils.add(entity.pos, Vec2Utils.scale(entity.vel, dt));
                    }
                }
            });
        }
    }
    
    /**
     * Run collision detection and resolution
     * @param state Game state
     * @param tick Current tick
     */
    public function stepCollision(state: GameModelState, tick: Int): Void {
        // Simplified collision detection
        // In practice, would implement spatial hash and SAT collision detection
        
        final entities = [];
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive) {
                    entities.push(entity);
                }
            });
        }
        
        // Simple AABB collision detection with broad-phase distance filtering
        final unitPixels = NecrotonEngine.Config.unitPixels;
        
        for (i in 0...entities.length) {
            for (j in i + 1...entities.length) {
                final a = entities[i];
                final b = entities[j];

                // Broad-phase: Use actual collider dimensions for more precise collision detection
                final widthA = a.colliderWidth * unitPixels;
                final heightA = a.colliderHeight * unitPixels;
                final widthB = b.colliderWidth * unitPixels;
                final heightB = b.colliderHeight * unitPixels;
                
                // Calculate maximum possible distance between collider centers
                final maxDistanceX = (widthA + widthB) / 2;
                final maxDistanceY = (heightA + heightB) / 2;
                final maxDistanceSquared = maxDistanceX * maxDistanceX + maxDistanceY * maxDistanceY;
                
                // Calculate actual distance between entity centers
                final distanceSquared = Vec2Utils.distanceSquared(a.pos, b.pos);
                
                // Skip collision check if entities are too far apart
                if (distanceSquared > maxDistanceSquared) {
                    continue;
                }

                final collisionResult = checkCollision(a, b);
                if (collisionResult.intersects) {
                    resolveCollision(collisionResult.rectA, a, collisionResult.rectB, b);
                }
            }
        }
    }
    
    /**
     * Register collider for entity
     * @param entity Entity with collider
     */
    public function registerCollider(entity: Dynamic): Void {
        // Simplified - in practice would add to spatial hash
    }

    /**
     * Unregister collider for entity
     * @param entityId Entity ID
     */
    public function unregisterCollider(entityId: Int): Void {
        // Simplified - in practice would remove from spatial hash
    }

    private function checkCollision(a: BaseEngineEntity, b: BaseEngineEntity): { intersects: Bool, rectA: Rect, rectB: Rect } {
        // Create rectangles for collision detection
        final unitPixels = NecrotonEngine.Config.unitPixels;
        final colliderAWidth = Std.int(a.colliderWidth * unitPixels);
        final colliderAHeight = Std.int(a.colliderHeight * unitPixels);
        final colliderBWidth = Std.int(b.colliderWidth * unitPixels);
        final colliderBHeight = Std.int(b.colliderHeight * unitPixels);
        final rectA = RectUtils.create(a.pos.x, a.pos.y, colliderAWidth, colliderAHeight);
        final rectB = RectUtils.create(b.pos.x, b.pos.y, colliderBWidth, colliderBHeight);
        
        final intersects = RectUtils.intersectsRect(rectA, rectB);
        
        return {
            intersects: intersects,
            rectA: rectA,
            rectB: rectB
        };
    }
    
    private function resolveCollision(rectA: Rect, entityA: BaseEngineEntity, rectB: Rect, entityB: BaseEngineEntity): Void {
        // Get penetration depth for proper AABB separation
        final separation = RectUtils.getIntersectionDepth(rectA, rectB);
        
        // Check if either entity is a collider
        final aIsCollider = entityA.type == EntityType.COLLIDER;
        final bIsCollider = entityB.type == EntityType.COLLIDER;
        
        // If either entity is a collider, we need to prevent them from moving into each other
        if (aIsCollider || bIsCollider) {
            final collider = cast(aIsCollider ? entityA : entityB, EngineColliderEntity);
            final entity = aIsCollider ? entityB : entityA;
            
            // If collider is not passable, we need to prevent the entity from moving into it
            if (!collider.passable) {
                // Push entity completely out of collider
                entity.applyMovementCorrection(separation);
            }
            
            // Handle collider trigger
            if (collider.isTrigger) {
                trace("Collider trigger activated: " + collider.id + " by entity: " + entity.id);
            }
        }
    }
}
