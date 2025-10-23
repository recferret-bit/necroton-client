package engine.modules;

import engine.geometry.RectUtils;
import engine.geometry.Vec2Utils;
import engine.model.EntityType;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;

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
        
        // Debug: Check if we have entities
        if (entities.length > 0) {
            trace('COLLISION STEP: Found ' + Std.string(entities.length) + ' alive entities');
        }
        
        // Simple AABB collision detection
        for (i in 0...entities.length) {
            for (j in i + 1...entities.length) {
                final a = entities[i];
                final b = entities[j];
                
                if (checkCollision(a, b)) {
                    resolveCollision(a, b);
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
    
    private function checkCollision(a: BaseEngineEntity, b: BaseEngineEntity): Bool {
        // Create rectangles for collision detection
        final colliderWidth = Std.int(a.colliderWidth * 32);
        final colliderHeight = Std.int(a.colliderHeight * 32);
        final rectA = RectUtils.create(a.pos.x, a.pos.y, colliderWidth, colliderHeight);
        final rectB = RectUtils.create(b.pos.x, b.pos.y, colliderWidth, colliderHeight);
        
        final intersects = RectUtils.intersectsRect(rectA, rectB);
        
        // Debug collision detection
        if (intersects) {
            trace('COLLISION DETECTED:');
            trace('  Entity A: type=' + Std.string(a.type) + ', pos=(' + Std.string(a.pos.x) + ', ' + Std.string(a.pos.y) + '), size=' + Std.string(a.colliderWidth) + 'x' + Std.string(a.colliderHeight));
            trace('  Entity B: type=' + Std.string(b.type) + ', pos=(' + Std.string(b.pos.x) + ', ' + Std.string(b.pos.y) + '), size=' + Std.string(b.colliderWidth) + 'x' + Std.string(b.colliderHeight));
            trace('  Rect A: x=' + Std.string(rectA.x) + ', y=' + Std.string(rectA.y) + ', w=' + Std.string(rectA.width) + ', h=' + Std.string(rectA.height));
            trace('  Rect B: x=' + Std.string(rectB.x) + ', y=' + Std.string(rectB.y) + ', w=' + Std.string(rectB.width) + ', h=' + Std.string(rectB.height));
        }
        
        return intersects;
    }
    
    private function resolveCollision(a: Dynamic, b: Dynamic): Void {
        trace('RESOLVING COLLISION between ' + Std.string(a.type) + ' and ' + Std.string(b.type));
        
        // Create rectangles for collision resolution
        final rectA = RectUtils.create(a.pos.x, a.pos.y, a.colliderWidth, a.colliderHeight);
        final rectB = RectUtils.create(b.pos.x, b.pos.y, b.colliderWidth, b.colliderHeight);
        
        // Get penetration depth for proper AABB separation
        final separation = RectUtils.getIntersectionDepth(rectA, rectB);
        trace('  Separation vector: (' + Std.string(separation.x) + ', ' + Std.string(separation.y) + ')');
        
        // Check if either entity is a collider
        final aIsCollider = a.type == EntityType.COLLIDER;
        final bIsCollider = b.type == EntityType.COLLIDER;
        trace('  aIsCollider: ' + Std.string(aIsCollider) + ', bIsCollider: ' + Std.string(bIsCollider));
        
        if (aIsCollider || bIsCollider) {
            final collider = aIsCollider ? a : b;
            final entity = aIsCollider ? b : a;
            
            // Check if collider has passable property and if it's non-passable
            final isPassable = Reflect.hasField(collider, "passable") && Reflect.field(collider, "passable") == true;
            
            if (!isPassable) {
                // Push entity completely out of collider
                if (aIsCollider) {
                    // a is collider, push b away
                    entity.pos = Vec2Utils.sub(entity.pos, separation);
                } else {
                    // b is collider, push a away
                    entity.pos = Vec2Utils.add(entity.pos, separation);
                }
                
                // Zero velocity to stop movement
                entity.vel.x = 0;
                entity.vel.y = 0;
            }
            
            // Handle trigger
            final isTrigger = Reflect.hasField(collider, "isTrigger") && Reflect.field(collider, "isTrigger") == true;
            if (isTrigger) {
                trace("Collider trigger activated: " + collider.id + " by entity: " + entity.id);
            }
        } else {
            // Regular entity-to-entity collision
            // Apply separation to both entities
            a.pos = Vec2Utils.add(a.pos, Vec2Utils.scale(separation, 0.5));
            b.pos = Vec2Utils.sub(b.pos, Vec2Utils.scale(separation, 0.5));
        }
    }
}
