package game.mvp.view;

import h2d.Object;
import h2d.Graphics;
import engine.model.EntityType;
import game.mvp.model.GameClientState;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.CharacterModel;
import game.mvp.model.entities.ConsumableModel;
import game.mvp.model.entities.EffectModel;
import game.mvp.view.entities.BaseGameEntityView;
import game.mvp.view.entities.CharacterEntityView;
import game.mvp.view.entities.ConsumableEntityView;
import game.mvp.view.entities.EffectEntityView;
import game.mvp.view.entities.ColliderEntityView;

/**
 * Game view orchestrator
 * Manages view lifecycle, synchronization with models, and visual hierarchy
 * Handles view creation, updates, and destruction with object pooling
 */
class GameViewOrchestrator {
    // Core components
    private var gameClientState: GameClientState;
    private var entityViewPool: EntityViewPool;
    private var parent: Object;
    
    // View management
    private var entityViews: Map<Int, BaseGameEntityView>;
    private var viewLayers: Map<EntityType, Object>;
    
    // Debug graphics
    private var debugGraphics: Graphics;
    private var showDebugInfo: Bool;
    
    // Configuration
    private var enableObjectPooling: Bool;
    private var enableInterpolation: Bool;
    
    public function new(gameClientState: GameClientState, parent: Object) {
        this.gameClientState = gameClientState;
        this.parent = parent;
        
        // Initialize components
        entityViewPool = new EntityViewPool();
        entityViews = new Map<Int, BaseGameEntityView>();
        viewLayers = new Map<EntityType, Object>();
        
        // Configuration
        enableObjectPooling = true;
        enableInterpolation = true;
        showDebugInfo = false;
        
        // Create view layers
        createViewLayers();
        
        // Create debug graphics
        createDebugGraphics();
    }
    
    /**
     * Create view layers for organization
     */
    private function createViewLayers(): Void {
        // Character layer
        final characterLayer = new Object(parent);
        viewLayers.set(EntityType.CHARACTER, characterLayer);
        
        // Consumable layer
        final consumableLayer = new Object(parent);
        viewLayers.set(EntityType.CONSUMABLE, consumableLayer);
        
        // Effect layer
        final effectLayer = new Object(parent);
        viewLayers.set(EntityType.EFFECT, effectLayer);
        
        // Collider layer
        final colliderLayer = new Object(parent);
        viewLayers.set(EntityType.COLLIDER, colliderLayer);
    }
    
    /**
     * Create debug graphics
     */
    private function createDebugGraphics(): Void {
        debugGraphics = new Graphics(parent);
    }
    
    /**
     * Update all views
     */
    public function update(dt: Float): Void {
        // Update all active views
        for (view in entityViews) {
            if (view.isViewInitialized()) {
                view.update();
            }
        }
        
        // Update debug graphics
        if (showDebugInfo) {
            updateDebugGraphics();
        }
    }
    
    /**
     * Sync views with models
     */
    public function syncWithModels(): Void {
        // Get all models from game state
        var allModels = gameClientState.getAliveEntities();
        
        // Track which models have views
        var modelsWithViews = new Map<Int, Bool>();
        
        // Update existing views
        for (model in allModels) {
            var view = entityViews.get(model.id);
            if (view != null) {
                // Update existing view
                view.update();
                modelsWithViews.set(model.id, true);
            } else {
                // Create new view for model
                createViewForModel(model);
                modelsWithViews.set(model.id, true);
            }
        }
        
        // Remove views for models that no longer exist
        var viewsToRemove = [];
        for (entityId in entityViews.keys()) {
            if (!modelsWithViews.exists(entityId)) {
                viewsToRemove.push(entityId);
            }
        }
        
        for (entityId in viewsToRemove) {
            removeView(entityId);
        }
    }
    
    /**
     * Create view for model
     */
    private function createViewForModel(model: BaseEntityModel): Void {
        var view: BaseGameEntityView = null;
        var layer: Object = null;
        
        // Get appropriate layer
        switch (model.type) {
            case CHARACTER:
                layer = viewLayers.get(EntityType.CHARACTER);
            case CONSUMABLE:
                layer = viewLayers.get(EntityType.CONSUMABLE);
            case EFFECT:
                layer = viewLayers.get(EntityType.EFFECT);
            case COLLIDER:
                layer = viewLayers.get(EntityType.COLLIDER);
            default:
                layer = viewLayers.get(EntityType.CHARACTER); // Default fallback
        }
        
        if (layer == null) return;
        
        // Acquire view from pool or create new
        if (enableObjectPooling && model.type != EntityType.COLLIDER) {
            // Skip object pooling for colliders as requested
            view = entityViewPool.acquire(model.type, layer);
        } else {
            switch (model.type) {
                case EntityType.CHARACTER:
                    view = new CharacterEntityView(layer);
                case EntityType.CONSUMABLE:
                    view = new ConsumableEntityView(layer);
                case EntityType.EFFECT:
                    view = new EffectEntityView(layer);
                case EntityType.COLLIDER:
                    view = new ColliderEntityView(layer);
                default:
                    view = new CharacterEntityView(layer); // Default fallback
            }
        }
        
        if (view != null) {
            // Initialize view with model
            view.initialize(model);
            
            // Store reference
            entityViews.set(model.id, view);
        }
    }
    
    /**
     * Remove view by entity ID
     */
    private function removeView(entityId: Int): Void {
        var view = entityViews.get(entityId);
        if (view != null) {
            // Remove from map
            entityViews.remove(entityId);
            
            // Return to pool or destroy
            if (enableObjectPooling) {
                entityViewPool.release(view);
            } else {
                view.destroy();
            }
        }
    }
    
    /**
     * Get view by entity ID
     */
    public function getView(entityId: Int): BaseGameEntityView {
        return entityViews.get(entityId);
    }
    
    /**
     * Get all views of specific type
     */
    public function getViewsByType(type: EntityType): Array<BaseGameEntityView> {
        var result = [];
        for (view in entityViews) {
            if (view.getModel() != null && view.getModel().type == type) {
                result.push(view);
            }
        }
        return result;
    }
    
    /**
     * Get character views
     */
    public function getCharacterViews(): Array<CharacterEntityView> {
        var result = [];
        for (view in entityViews) {
            if (Std.isOfType(view, CharacterEntityView)) {
                result.push(cast view);
            }
        }
        return result;
    }
    
    /**
     * Get consumable views
     */
    public function getConsumableViews(): Array<ConsumableEntityView> {
        var result = [];
        for (view in entityViews) {
            if (Std.isOfType(view, ConsumableEntityView)) {
                result.push(cast view);
            }
        }
        return result;
    }
    
    /**
     * Get effect views
     */
    public function getEffectViews(): Array<EffectEntityView> {
        var result = [];
        for (view in entityViews) {
            if (Std.isOfType(view, EffectEntityView)) {
                result.push(cast view);
            }
        }
        return result;
    }
    
    /**
     * Update debug graphics
     */
    private function updateDebugGraphics(): Void {
        debugGraphics.clear();
        
        // Draw entity count info
        var y = 10;
        var lineHeight = 15;
        
        debugGraphics.beginFill(0x000000, 0.7);
        debugGraphics.drawRect(10, 10, 200, 100);
        debugGraphics.endFill();
        
        // Draw pool statistics
        var poolSummary = entityViewPool.getPoolSummary();
        debugGraphics.setColor(0xFFFFFF);
        // Note: Graphics doesn't have drawText, we'll use simple shapes for debug info
        // This is a simplified debug display
        debugGraphics.drawRect(15, y, 10, 10); // Simple indicator
        y += lineHeight;
        
        debugGraphics.drawRect(15, y, 10, 10); // Total Pooled indicator
        y += lineHeight;
        
        debugGraphics.drawRect(15, y, 10, 10); // Total Active indicator
        y += lineHeight;
        
        debugGraphics.drawRect(15, y, 10, 10); // Characters indicator
        y += lineHeight;
        
        debugGraphics.drawRect(15, y, 10, 10); // Consumables indicator
        y += lineHeight;
        
        debugGraphics.drawRect(15, y, 10, 10); // Effects indicator
    }
    
    /**
     * Set debug info visibility
     */
    public function setDebugInfoVisible(visible: Bool): Void {
        showDebugInfo = visible;
        if (debugGraphics != null) {
            debugGraphics.visible = visible;
        }
    }
    
    /**
     * Set object pooling enabled
     */
    public function setObjectPoolingEnabled(enabled: Bool): Void {
        enableObjectPooling = enabled;
    }
    
    /**
     * Set interpolation enabled
     */
    public function setInterpolationEnabled(enabled: Bool): Void {
        enableInterpolation = enabled;
    }
    
    /**
     * Get view count
     */
    public function getViewCount(): Int {
        var count = 0;
        for (view in entityViews) {
            count++;
        }
        return count;
    }
    
    /**
     * Get view count by type
     */
    public function getViewCountByType(type: EntityType): Int {
        return getViewsByType(type).length;
    }
    
    /**
     * Clear all views
     */
    public function clear(): Void {
        // Remove all views
        for (entityId in entityViews.keys()) {
            removeView(entityId);
        }
        
        // Clear entity views map
        entityViews.clear();
    }
    
    /**
     * Destroy orchestrator
     */
    public function destroy(): Void {
        // Clear all views
        clear();
        
        // Clear view layers
        for (layer in viewLayers) {
            layer.remove();
        }
        viewLayers.clear();
        
        // Clear debug graphics
        if (debugGraphics != null) {
            debugGraphics.remove();
            debugGraphics = null;
        }
        
        // Clear pool
        entityViewPool.clear();
    }
    
    /**
     * Get orchestrator summary for debugging
     */
    public function getOrchestratorSummary(): Dynamic {
        return {
            viewCount: getViewCount(),
            characterViews: getViewCountByType(CHARACTER),
            consumableViews: getViewCountByType(CONSUMABLE),
            effectViews: getViewCountByType(EFFECT),
            poolSummary: entityViewPool.getPoolSummary(),
            objectPoolingEnabled: enableObjectPooling,
            interpolationEnabled: enableInterpolation
        };
    }
}
