package game.mvp.view;

import h2d.Object;
import engine.model.EntityType;
import game.mvp.view.entities.BaseGameEntityView;
import game.mvp.view.entities.CharacterEntityView;
import game.mvp.view.entities.ConsumableEntityView;
import game.mvp.view.entities.EffectEntityView;

/**
 * Object pool for view entities
 * Manages typed pools for efficient view entity reuse
 * Implements acquire/release pattern for object pooling
 */
class EntityViewPool {
    // Typed pools for each entity type
    private var characterPool: Array<BaseGameEntityView>;
    private var consumablePool: Array<BaseGameEntityView>;
    private var effectPool: Array<BaseGameEntityView>;
    
    // Pool statistics
    private var poolStats: Map<EntityType, PoolStats>;
    
    // Configuration
    private var maxPoolSize: Int;
    private var initialPoolSize: Int;
    
    public function new(maxPoolSize: Int = 50, initialPoolSize: Int = 5) {
        this.maxPoolSize = maxPoolSize;
        this.initialPoolSize = initialPoolSize;
        
        // Initialize pools
        characterPool = [];
        consumablePool = [];
        effectPool = [];
        
        // Initialize statistics
        poolStats = new Map<EntityType, PoolStats>();
        poolStats.set(CHARACTER, new PoolStats());
        poolStats.set(CONSUMABLE, new PoolStats());
        poolStats.set(EFFECT, new PoolStats());
        
        // Pre-populate pools
        initializePools();
    }
    
    /**
     * Initialize pools with initial objects
     */
    private function initializePools(): Void {
        // Pre-create character views
        for (i in 0...initialPoolSize) {
            var view: BaseGameEntityView = new CharacterEntityView();
            view.setPoolType(CHARACTER);
            view.reset();
            characterPool.push(view);
        }
        
        // Pre-create consumable views
        for (i in 0...initialPoolSize) {
            var view: BaseGameEntityView = new ConsumableEntityView();
            view.setPoolType(CONSUMABLE);
            view.reset();
            consumablePool.push(view);
        }
        
        // Pre-create effect views
        for (i in 0...initialPoolSize) {
            var view: BaseGameEntityView = new EffectEntityView();
            view.setPoolType(EFFECT);
            view.reset();
            effectPool.push(view);
        }
    }
    
    /**
     * Acquire view from pool
     */
    public function acquire(type: EntityType, parent: Object = null): BaseGameEntityView {
        var view: BaseGameEntityView = null;
        
        switch (type) {
            case CHARACTER:
                view = getFromPool(characterPool);
                if (view == null) {
                    view = new CharacterEntityView(parent);
                    view.setPoolType(CHARACTER);
                }
            case CONSUMABLE:
                view = getFromPool(consumablePool);
                if (view == null) {
                    view = new ConsumableEntityView(parent);
                    view.setPoolType(CONSUMABLE);
                }
            case EFFECT:
                view = getFromPool(effectPool);
                if (view == null) {
                    view = new EffectEntityView(parent);
                    view.setPoolType(EFFECT);
                }
            default:
                view = null;
        }
        
        if (view != null) {
            // Set parent if provided
            if (parent != null && view.parent != parent) {
                parent.addChild(view);
            }
            
            // Prepare for use
            view.acquire();
            
            // Update statistics
            var stats = poolStats.get(type);
            stats.acquired++;
            stats.activeCount++;
        }
        
        return view;
    }
    
    /**
     * Release view back to pool
     */
    public function release(view: BaseGameEntityView): Void {
        if (view == null || !view.isInObjectPool()) {
            return;
        }
        
        var type = view.getPoolType();
        var stats = poolStats.get(type);
        
        // Reset view for reuse
        view.release();
        
        // Add back to appropriate pool
        switch (type) {
            case CHARACTER:
                if (characterPool.length < maxPoolSize) {
                    characterPool.push(view);
                } else {
                    // Pool is full, destroy the view
                    view.destroy();
                }
            case CONSUMABLE:
                if (consumablePool.length < maxPoolSize) {
                    consumablePool.push(view);
                } else {
                    view.destroy();
                }
            case EFFECT:
                if (effectPool.length < maxPoolSize) {
                    effectPool.push(view);
                } else {
                    view.destroy();
                }
            default:
                view.destroy();
        }
        
        // Update statistics
        stats.released++;
        stats.activeCount--;
    }
    
    /**
     * Get view from pool (internal method)
     */
    private function getFromPool(pool: Array<BaseGameEntityView>): BaseGameEntityView {
        if (pool.length > 0) {
            return pool.pop();
        }
        return null;
    }
    
    /**
     * Get pool size for specific type
     */
    public function getPoolSize(type: EntityType): Int {
        switch (type) {
            case CHARACTER:
                return characterPool.length;
            case CONSUMABLE:
                return consumablePool.length;
            case EFFECT:
                return effectPool.length;
            default:
                return 0;
        }
    }
    
    /**
     * Get total pool size
     */
    public function getTotalPoolSize(): Int {
        return characterPool.length + consumablePool.length + effectPool.length;
    }
    
    /**
     * Get active count for specific type
     */
    public function getActiveCount(type: EntityType): Int {
        var stats = poolStats.get(type);
        return stats.activeCount;
    }
    
    /**
     * Get total active count
     */
    public function getTotalActiveCount(): Int {
        var total = 0;
        for (stats in poolStats) {
            total += stats.activeCount;
        }
        return total;
    }
    
    /**
     * Get pool statistics
     */
    public function getPoolStats(type: EntityType): PoolStats {
        return poolStats.get(type);
    }
    
    /**
     * Get all pool statistics
     */
    public function getAllPoolStats(): Map<EntityType, PoolStats> {
        return poolStats;
    }
    
    /**
     * Clear all pools
     */
    public function clear(): Void {
        // Destroy all pooled objects
        for (view in characterPool) {
            view.destroy();
        }
        for (view in consumablePool) {
            view.destroy();
        }
        for (view in effectPool) {
            view.destroy();
        }
        
        // Clear pools
        characterPool = [];
        consumablePool = [];
        effectPool = [];
        
        // Reset statistics
        for (stats in poolStats) {
            stats.reset();
        }
    }
    
    /**
     * Clean up pools (remove excess objects)
     */
    public function cleanup(): Void {
        // Keep only initial pool size in each pool
        while (characterPool.length > initialPoolSize) {
            var view = characterPool.pop();
            view.destroy();
        }
        
        while (consumablePool.length > initialPoolSize) {
            var view = consumablePool.pop();
            view.destroy();
        }
        
        while (effectPool.length > initialPoolSize) {
            var view = effectPool.pop();
            view.destroy();
        }
    }
    
    /**
     * Get pool summary for debugging
     */
    public function getPoolSummary(): Dynamic {
        return {
            totalPooled: getTotalPoolSize(),
            totalActive: getTotalActiveCount(),
            characterPool: {
                pooled: characterPool.length,
                active: getActiveCount(CHARACTER),
                acquired: poolStats.get(CHARACTER).acquired,
                released: poolStats.get(CHARACTER).released
            },
            consumablePool: {
                pooled: consumablePool.length,
                active: getActiveCount(CONSUMABLE),
                acquired: poolStats.get(CONSUMABLE).acquired,
                released: poolStats.get(CONSUMABLE).released
            },
            effectPool: {
                pooled: effectPool.length,
                active: getActiveCount(EFFECT),
                acquired: poolStats.get(EFFECT).acquired,
                released: poolStats.get(EFFECT).released
            }
        };
    }
}

/**
 * Pool statistics container
 */
class PoolStats {
    public var acquired: Int;
    public var released: Int;
    public var activeCount: Int;
    
    public function new() {
        acquired = 0;
        released = 0;
        activeCount = 0;
    }
    
    public function reset(): Void {
        acquired = 0;
        released = 0;
        activeCount = 0;
    }
}
