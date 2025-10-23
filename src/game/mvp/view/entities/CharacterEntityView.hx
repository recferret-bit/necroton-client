package game.mvp.view.entities;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Graphics;
import game.mvp.model.entities.CharacterModel;
import game.mvp.model.entities.BaseEntityModel;

/**
 * Character entity view extending BaseGameEntityView
 * Adds character-specific visual features like health bars and movement indicators
 */
class CharacterEntityView extends BaseGameEntityView {
    // Character-specific visual components
    private var nameText: h2d.Text;
    private var levelText: h2d.Text;
    private var movementTrail: Array<{x: Float, y: Float, alpha: Float}>;
    
    // Visual state
    private var showName: Bool;
    private var showLevel: Bool;
    private var trailLength: Int;
    
    public function new(parent: Object = null) {
        super(parent);
        
        // Initialize character-specific properties
        showName = false;
        showLevel = true;
        trailLength = 10;
        movementTrail = [];
    }
    
    /**
     * Initialize character view
     */
    override public function initialize(model: BaseEntityModel): Void {
        super.initialize(model);
        
        // Create character-specific visuals
        createCharacterVisuals();
    }
    
    /**
     * Create character-specific visual elements
     */
    private function createCharacterVisuals(): Void {
        final characterModel = cast(model, CharacterModel);
        if (characterModel == null) return;
        
        // Create name text
        if (showName) {
            createNameText();
        }
        
        // Create level text
        if (showLevel) {
            createLevelText();
        }
        
        // Show health bar for characters
        showHealthBar();
    }
    
    /**
     * Create name text display
     */
    private function createNameText(): Void {
        if (nameText != null) {
            nameText.remove();
        }
        
        final characterModel = cast(model, CharacterModel);
        if (characterModel == null) return;
        
        nameText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        nameText.text = characterModel.ownerId;
        nameText.textColor = 0xFFFFFF;
        nameText.x = -nameText.textWidth * 0.5;
        nameText.y = -model.colliderHeight * 8 - 20;
    }
    
    /**
     * Create level text display
     */
    private function createLevelText(): Void {
        if (levelText != null) {
            levelText.remove();
        }
        
        final characterModel = cast(model, CharacterModel);
        if (characterModel == null) return;
        
        levelText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        levelText.text = "Lv." + characterModel.level;
        levelText.textColor = 0xFFFF00;
        levelText.x = -levelText.textWidth * 0.5;
        levelText.y = -model.colliderHeight * 8 - 35;
    }
    
    /**
     * Update character view
     */
    override public function update(): Void {
        super.update();
        
        if (!isInitialized || model == null || !model.isAlive) {
            return;
        }
        
        var characterModel = cast(model, CharacterModel);
        if (characterModel == null) return;
        
        // Update character-specific visuals
        updateCharacterVisuals(characterModel);
        
        // Update movement trail
        updateMovementTrail();
        
        // Update health bar
        updateHealthBar();
    }
    
    /**
     * Update character-specific visual elements
     */
    private function updateCharacterVisuals(characterModel: CharacterModel): Void {
        // Update level text
        if (levelText != null) {
            levelText.text = "Lv." + characterModel.level;
            levelText.x = -levelText.textWidth * 0.5;
        }
        
        // Update visual scale based on health
        final healthPercent = characterModel.getHealthPercentage();
        if (healthPercent < 0.3) {
            // Flash red when low health
            final flashIntensity = Math.sin(hxd.Timer.lastTimeStamp * 10) * 0.5 + 0.5;
            model.visualScale = 1.0 + flashIntensity * 0.2;
        } else {
            model.visualScale = 1.0;
        }
    }
    
    /**
     * Update movement trail effect
     */
    private function updateMovementTrail(): Void {
        final characterModel = cast(model, CharacterModel);
        if (characterModel == null || !characterModel.isMoving) {
            return;
        }
        
        // Add current position to trail
        movementTrail.push({
            x: x,
            y: y,
            alpha: 1.0
        });
        
        // Limit trail length
        if (movementTrail.length > trailLength) {
            movementTrail.shift();
        }
        
        // Fade trail points
        for (point in movementTrail) {
            point.alpha -= 0.1;
        }
        
        // Remove faded points
        movementTrail = movementTrail.filter(function(point) {
            return point.alpha > 0.1;
        });
    }
    
    /**
     * Render movement trail
     */
    public function renderTrail(graphics: Graphics): Void {
        if (movementTrail.length < 2) return;
        
        graphics.clear();
        graphics.lineStyle(2, 0xFFFFFF, 0.5);
        
        for (i in 1...movementTrail.length) {
            final prev = movementTrail[i - 1];
            final curr = movementTrail[i];
            
            graphics.lineStyle(2, 0xFFFFFF, prev.alpha);
            graphics.moveTo(prev.x, prev.y);
            graphics.lineTo(curr.x, curr.y);
        }
    }
    
    /**
     * Set name visibility
     */
    public function setNameVisible(visible: Bool): Void {
        showName = visible;
        if (nameText != null) {
            nameText.visible = visible;
        }
    }
    
    /**
     * Set level visibility
     */
    public function setLevelVisible(visible: Bool): Void {
        showLevel = visible;
        if (levelText != null) {
            levelText.visible = visible;
        }
    }
    
    /**
     * Set trail length
     */
    public function setTrailLength(length: Int): Void {
        trailLength = length;
        if (movementTrail.length > length) {
            movementTrail = movementTrail.slice(-length);
        }
    }
    
    /**
     * Get character model
     */
    public function getCharacterModel(): CharacterModel {
        return cast(model, CharacterModel);
    }
    
    /**
     * Reset for object pooling
     */
    override public function reset(): Void {
        // Clear character-specific visuals
        if (nameText != null) {
            nameText.remove();
            nameText = null;
        }
        
        if (levelText != null) {
            levelText.remove();
            levelText = null;
        }
        
        movementTrail = [];
        
        // Call parent reset
        super.reset();
    }
    
    /**
     * Destroy character view
     */
    override public function destroy(): Void {
        if (nameText != null) {
            nameText.remove();
            nameText = null;
        }
        
        if (levelText != null) {
            levelText.remove();
            levelText = null;
        }
        
        movementTrail = [];
        
        super.destroy();
    }
}
