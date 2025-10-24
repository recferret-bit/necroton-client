package game.mvp.view.entities;

import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.ConsumableModel;
import h2d.Graphics;
import h2d.Object;

/**
 * Consumable entity view extending BaseGameEntityView
 * Adds consumable-specific visual features like glow effects and quantity display
 */
class ConsumableEntityView extends BaseGameEntityView {
    // Consumable-specific visual components
    private var glowEffect: Graphics;
    private var quantityText: h2d.Text;
    private var rarityGlow: Graphics;
    
    // Visual state
    private var showQuantity: Bool;
    private var glowIntensity: Float;
    private var pulsePhase: Float;
    
    public function new(parent: Object = null) {
        super(parent);
        
        // Initialize consumable-specific properties
        showQuantity = true;
        glowIntensity = 0.0;
        pulsePhase = 0.0;
    }
    
    /**
     * Initialize consumable view
     */
    override public function initialize(model: BaseEntityModel): Void {
        super.initialize(model);
        
        // Create consumable-specific visuals
        createConsumableVisuals();
    }
    
    /**
     * Create consumable-specific visual elements
     */
    private function createConsumableVisuals(): Void {
        var consumableModel = cast(model, ConsumableModel);
        if (consumableModel == null) return;
        
        // Create glow effect
        createGlowEffect();
        
        // Create quantity text
        if (showQuantity) {
            createQuantityText();
        }
        
        // Create rarity glow
        createRarityGlow();
    }
    
    /**
     * Create glow effect around consumable
     */
    private function createGlowEffect(): Void {
        if (glowEffect != null) {
            glowEffect.remove();
        }
        
        glowEffect = new Graphics(this);
        var consumableModel = cast(model, ConsumableModel);
        if (consumableModel == null) return;
        
        var glowSize = Math.max(model.colliderWidth, model.colliderHeight) * 20; // Slightly larger than base entity
        var glowColor = model.color;
        
        // Create pulsing glow
        glowEffect.beginFill(glowColor, 0.3);
        glowEffect.drawCircle(0, 0, glowSize);
        glowEffect.endFill();
    }
    
    /**
     * Create quantity text display
     */
    private function createQuantityText(): Void {
        if (quantityText != null) {
            quantityText.remove();
        }
        
        var consumableModel = cast(model, ConsumableModel);
        if (consumableModel == null) return;
        
        quantityText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        quantityText.text = "x" + consumableModel.quantity;
        quantityText.textColor = 0xFFFFFF;
        quantityText.x = -quantityText.textWidth * 0.5;
        quantityText.y = -model.colliderHeight * 8 - 10;
    }
    
    /**
     * Create rarity glow effect
     */
    private function createRarityGlow(): Void {
        if (rarityGlow != null) {
            rarityGlow.remove();
        }
        
        var consumableModel = cast(model, ConsumableModel);
        if (consumableModel == null) return;
        
        if (consumableModel.glowIntensity > 0) {
            rarityGlow = new Graphics(this);
            var glowSize = Math.max(model.colliderWidth, model.colliderHeight) * 25;
            var glowColor = getRarityColor(consumableModel.rarity);
            
            rarityGlow.beginFill(glowColor, consumableModel.glowIntensity * 0.5);
            rarityGlow.drawCircle(0, 0, glowSize);
            rarityGlow.endFill();
        }
    }
    
    /**
     * Get color based on rarity
     */
    private function getRarityColor(rarity: String): Int {
        switch (rarity) {
            case "common":
                return 0xFFFFFF;
            case "rare":
                return 0x0088FF;
            case "epic":
                return 0x8800FF;
            case "legendary":
                return 0xFF8800;
            default:
                return 0xFFFFFF;
        }
    }
    
    /**
     * Update consumable view
     */
    override public function update(): Void {
        super.update();
        
        if (!isInitialized || model == null || !model.isAlive) {
            return;
        }
        
        var consumableModel = cast(model, ConsumableModel);
        if (consumableModel == null) return;
        
        // Update consumable-specific visuals
        updateConsumableVisuals(consumableModel);
    }
    
    /**
     * Update consumable-specific visual elements
     */
    private function updateConsumableVisuals(consumableModel: ConsumableModel): Void {
        // Update quantity text
        if (quantityText != null) {
            quantityText.text = "x" + consumableModel.quantity;
            quantityText.x = -quantityText.textWidth * 0.5;
        }
        
        // Update glow effect
        updateGlowEffect(consumableModel);
        
        // Update rarity glow
        updateRarityGlow(consumableModel);
    }
    
    /**
     * Update glow effect animation
     */
    private function updateGlowEffect(consumableModel: ConsumableModel): Void {
        if (glowEffect == null) return;
        
        // Update pulse phase
        pulsePhase += 0.1;
        if (pulsePhase > Math.PI * 2) {
            pulsePhase -= Math.PI * 2;
        }
        
        // Update glow intensity
        var pulseIntensity = Math.sin(pulsePhase) * 0.3 + 0.7;
        glowIntensity = pulseIntensity;
        
        // Update glow visual
        glowEffect.clear();
        var glowSize = Math.max(model.colliderWidth, model.colliderHeight) * 20 * (0.8 + pulseIntensity * 0.4);
        glowEffect.beginFill(model.color, 0.2 * pulseIntensity);
        glowEffect.drawCircle(0, 0, glowSize);
        glowEffect.endFill();
    }
    
    /**
     * Update rarity glow animation
     */
    private function updateRarityGlow(consumableModel: ConsumableModel): Void {
        if (rarityGlow == null) return;
        
        // Update rarity glow based on consumable's glow intensity
        rarityGlow.clear();
        if (consumableModel.glowIntensity > 0) {
            var glowSize = Math.max(model.colliderWidth, model.colliderHeight) * 25 * (1.0 + Math.sin(pulsePhase * 2) * 0.2);
            var glowColor = getRarityColor(consumableModel.rarity);
            var alpha = consumableModel.glowIntensity * 0.5 * (0.5 + Math.sin(pulsePhase * 1.5) * 0.5);
            
            rarityGlow.beginFill(glowColor, alpha);
            rarityGlow.drawCircle(0, 0, glowSize);
            rarityGlow.endFill();
        }
    }
    
    /**
     * Set quantity visibility
     */
    public function setQuantityVisible(visible: Bool): Void {
        showQuantity = visible;
        if (quantityText != null) {
            quantityText.visible = visible;
        }
    }
    
    /**
     * Get consumable model
     */
    public function getConsumableModel(): ConsumableModel {
        return cast(model, ConsumableModel);
    }
    
    /**
     * Reset for object pooling
     */
    override public function reset(): Void {
        // Clear consumable-specific visuals
        if (glowEffect != null) {
            glowEffect.remove();
            glowEffect = null;
        }
        
        if (quantityText != null) {
            quantityText.remove();
            quantityText = null;
        }
        
        if (rarityGlow != null) {
            rarityGlow.remove();
            rarityGlow = null;
        }
        
        glowIntensity = 0.0;
        pulsePhase = 0.0;
        
        // Call parent reset
        super.reset();
    }
    
    /**
     * Destroy consumable view
     */
    override public function destroy(): Void {
        if (glowEffect != null) {
            glowEffect.remove();
            glowEffect = null;
        }
        
        if (quantityText != null) {
            quantityText.remove();
            quantityText = null;
        }
        
        if (rarityGlow != null) {
            rarityGlow.remove();
            rarityGlow = null;
        }
        
        super.destroy();
    }
}
