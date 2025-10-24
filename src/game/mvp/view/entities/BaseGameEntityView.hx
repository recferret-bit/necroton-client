package game.mvp.view.entities;

import engine.model.entities.EntityType;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.presenter.GamePresenter;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Object;
import h2d.Tile;

/**
 * Base game entity view using Tile.fromColor approach
 * Extends h2d.Object with visual representation of engine entities
 * Supports object pooling for efficient reuse
 */
class BaseGameEntityView extends Object {
    // Visual components
    private var bitmap: Bitmap;
    private var graphics: Graphics;
    private var healthBar: Graphics;
    private var borderGraphics: Graphics;
    
    // Model reference
    private var model: BaseEntityModel;
    
    // Visual state
    private var lastModelUpdate: Int;
    private var isInitialized: Bool;
    
    // Pooling support
    private var isInPool: Bool;
    private var poolType: EntityType;
    
    public function new(parent: Object = null) {
        super(parent);
        
        // Create visual components
        graphics = new Graphics(this);
        healthBar = new Graphics(this);
        
        // Initialize state
        model = null;
        lastModelUpdate = 0;
        isInitialized = false;
        isInPool = false;
        poolType = CHARACTER;
    }
    
    /**
     * Initialize view with model data
     */
    public function initialize(model: BaseEntityModel): Void {
        this.model = model;
        this.poolType = model.type;
        
        // Create bitmap with color from model
        createVisualRepresentation();
        
        // Create border graphics for physics debugging if enabled
        if (GamePresenter.Config.visualSettings.drawPhysicsShapes) {
            createBorderGraphics();
        }
        
        // Set initial position
        updatePosition();
        
        isInitialized = true;
        lastModelUpdate = model.lastUpdateTick;
    }
    
    /**
     * Create visual representation using Tile.fromColor
     */
    private function createVisualRepresentation(): Void {
        if (bitmap != null) {
            bitmap.remove();
        }
        
        // Calculate size based on model collider dimensions
        final width = Math.floor(model.colliderWidth * GamePresenter.Config.engineConfig.unitPixels);
        final height = Math.floor(model.colliderHeight * GamePresenter.Config.engineConfig.unitPixels);
        var tile = Tile.fromColor(model.color, width, height);
        bitmap = new Bitmap(tile, this);
        
        // Center the bitmap
        bitmap.x = -width * 0.5;
        bitmap.y = -height * 0.5;
    }
    
    /**
     * Create border graphics for physics debugging
     */
    private function createBorderGraphics(): Void {
        if (borderGraphics != null) {
            borderGraphics.remove();
        }
        
        borderGraphics = new Graphics(this);
        
        // Draw border around entity using proper unit conversion
        final width = model.colliderWidth * GamePresenter.Config.engineConfig.unitPixels;
        final height = model.colliderHeight * GamePresenter.Config.engineConfig.unitPixels;
        
        borderGraphics.lineStyle(2, 0x0000FF, 1);
        borderGraphics.drawRect(-width * 0.5, -height * 0.5, width, height);
    }
    
    /**
     * Update view from model data
     */
    public function update(): Void {
        if (!isInitialized || model == null || !model.isAlive) {
            return;
        }
        
        // Check if model needs visual update
        if (model.needsVisualUpdate || model.lastUpdateTick != lastModelUpdate) {
            updateVisuals();
            lastModelUpdate = model.lastUpdateTick;
        }
        
        // Update position
        updatePosition();
        
        // Update rotation
        updateRotation();
        
        // Update scale
        updateScale();
    }
    
    /**
     * Update visual properties
     */
    private function updateVisuals(): Void {
        if (model.needsVisualUpdate) {
            // Recreate bitmap if color or size changed
            createVisualRepresentation();
            model.needsVisualUpdate = false;
        }
    }
    
    /**
     * Update position from model
     */
    private function updatePosition(): Void {
        if (model != null) {
            // Use interpolated render position for smooth movement
            x = model.renderPos.x;
            y = model.renderPos.y;
        }
    }
    
    /**
     * Update rotation from model
     */
    private function updateRotation(): Void {
        if (model != null) {
            rotation = model.rotation;
        }
    }
    
    /**
     * Update scale from model
     */
    private function updateScale(): Void {
        if (model != null) {
            scaleX = model.visualScale;
            scaleY = model.visualScale;
        }
    }
    
    /**
     * Update health bar (for characters)
     */
    private function updateHealthBar(): Void {
        if (model.type != CHARACTER) {
            healthBar.clear();
            return;
        }
        
        var characterModel = cast(model, game.mvp.model.entities.CharacterModel);
        if (characterModel == null) return;
        
        var healthPercent = characterModel.getHealthPercentage();
        var barWidth = 40;
        var barHeight = 4;
        
        healthBar.clear();
        healthBar.x = -barWidth * 0.5;
        healthBar.y = -model.colliderHeight * GamePresenter.Config.engineConfig.unitPixels - 10; // Position above entity
        
        // Background (red)
        healthBar.beginFill(0xFF0000);
        healthBar.drawRect(0, 0, barWidth, barHeight);
        healthBar.endFill();
        
        // Health (green)
        healthBar.beginFill(0x00FF00);
        healthBar.drawRect(0, 0, barWidth * healthPercent, barHeight);
        healthBar.endFill();
    }
    
    /**
     * Show health bar
     */
    public function showHealthBar(): Void {
        updateHealthBar();
    }
    
    /**
     * Hide health bar
     */
    public function hideHealthBar(): Void {
        healthBar.clear();
    }
    
    /**
     * Set border visibility for physics debugging
     */
    public function setBorderVisible(visible: Bool): Void {
        if (borderGraphics != null) {
            borderGraphics.visible = visible;
        }
    }
    
    /**
     * Get model reference
     */
    public function getModel(): BaseEntityModel {
        return model;
    }
    
    /**
     * Check if view is initialized
     */
    public function isViewInitialized(): Bool {
        return isInitialized;
    }
    
    /**
     * Reset for object pooling
     */
    public function reset(): Void {
        // Clear visual state
        if (bitmap != null) {
            bitmap.remove();
            bitmap = null;
        }
        
        graphics.clear();
        healthBar.clear();
        
        // Clear border graphics
        if (borderGraphics != null) {
            borderGraphics.remove();
            borderGraphics = null;
        }
        
        // Reset properties
        model = null;
        lastModelUpdate = 0;
        isInitialized = false;
        isInPool = true;
        
        // Reset transform
        x = 0;
        y = 0;
        rotation = 0;
        scaleX = 1;
        scaleY = 1;
        
        // Remove from parent
        if (parent != null) {
            remove();
        }
    }
    
    /**
     * Prepare for reuse from pool
     */
    public function acquire(): Void {
        isInPool = false;
        isInitialized = false;
    }
    
    /**
     * Return to pool
     */
    public function release(): Void {
        reset();
    }
    
    /**
     * Check if view is in pool
     */
    public function isInObjectPool(): Bool {
        return isInPool;
    }
    
    /**
     * Get pool type
     */
    public function getPoolType(): EntityType {
        return poolType;
    }
    
    /**
     * Set pool type
     */
    public function setPoolType(type: EntityType): Void {
        this.poolType = type;
    }
    
    /**
     * Destroy view (permanent removal)
     */
    public function destroy(): Void {
        if (bitmap != null) {
            bitmap.remove();
            bitmap = null;
        }
        
        graphics.clear();
        healthBar.clear();
        
        // Clear border graphics
        if (borderGraphics != null) {
            borderGraphics.remove();
            borderGraphics = null;
        }
        
        if (parent != null) {
            remove();
        }
        
        model = null;
        isInitialized = false;
        isInPool = false;
    }
}
