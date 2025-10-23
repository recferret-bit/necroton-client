package game.mvp.model.entities;

import engine.model.entities.impl.EngineConsumableEntity;
import engine.model.EntityType;

/**
 * Consumable entity model extending BaseEntityModel
 * Wraps engine ConsumableEntity with visual metadata
 */
class ConsumableModel extends BaseEntityModel {
    // Reference to engine consumable entity
    public var consumableEntity(get, never): EngineConsumableEntity;
    
    // Visual state
    public var glowIntensity: Float;
    public var pulsePhase: Float;
    
    public function new() {
        super();
        
        glowIntensity = 0.0;
        pulsePhase = 0.0;
    }
    
    private function get_consumableEntity(): EngineConsumableEntity {
        return cast(engineEntity, EngineConsumableEntity);
    }
    
    /**
     * Initialize with engine consumable entity
     */
    public function initializeConsumable(consumableEntity: EngineConsumableEntity): Void {
        super.initialize(consumableEntity);
        setConsumableVisuals();
    }
    
    /**
     * Set visual properties based on consumable type
     */
    private function setConsumableVisuals(): Void {
        if (consumableEntity == null) return;
        
        // Use effectId to determine visual type
        switch (consumableEntity.effectId) {
            case "health_potion":
                color = 0xFF0000;  // Red
            case "mana_potion":
                color = 0x0000FF;  // Blue
            case "strength_potion":
                color = 0xFF8000;  // Orange
            default:
                color = 0xFFFF00;  // Yellow
        }
        
        // Adjust glow based on charges (more charges = more glow)
        glowIntensity = Math.min(1.0, consumableEntity.charges / 10.0);
    }
    
    /**
     * Update consumable state
     */
    public function update(dt: Float): Void {
        // Update pulse animation
        pulsePhase += dt * 3.0; // 3 pulses per second
        if (pulsePhase > Math.PI * 2) {
            pulsePhase -= Math.PI * 2;
        }
        
        // Update visual scale based on pulse
        var pulseScale = 1.0 + Math.sin(pulsePhase) * 0.1;
        visualScale = pulseScale;
        needsVisualUpdate = true;
    }
    
    /**
     * Consume the item
     */
    public function consume(): Bool {
        if (consumableEntity != null && canConsume()) {
            consumableEntity.charges--;
            if (consumableEntity.charges <= 0) {
                consumableEntity.isAlive = false;
            }
            needsVisualUpdate = true;
            return true;
        }
        return false;
    }
    
    /**
     * Check if consumable can be consumed
     */
    public function canConsume(): Bool {
        return consumableEntity != null && consumableEntity.charges > 0 && isAlive;
    }
    
    /**
     * Get effect description
     */
    public function getEffectDescription(): String {
        if (consumableEntity == null) return "Unknown effect";
        
        switch (consumableEntity.effectId) {
            case "health_potion":
                return "Restores health";
            case "mana_potion":
                return "Restores mana";
            case "strength_potion":
                return "Increases power";
            default:
                return "Unknown effect";
        }
    }
    
    // Convenience getters that delegate to consumable entity
    public var effectId(get, never): String;
    public var charges(get, never): Int;
    public var stackable(get, never): Bool;
    public var useRange(get, never): Float;
    public var quantity(get, never): Int;
    public var rarity(get, never): String;
    public var consumableType(get, never): String;
    public var effectValue(get, never): Float;
    
    private function get_effectId(): String return consumableEntity != null ? consumableEntity.effectId : "";
    private function get_charges(): Int return consumableEntity != null ? consumableEntity.charges : 0;
    private function get_stackable(): Bool return consumableEntity != null ? consumableEntity.stackable : false;
    private function get_useRange(): Float return consumableEntity != null ? consumableEntity.useRange : 0;
    private function get_quantity(): Int return consumableEntity != null ? consumableEntity.charges : 0;
    private function get_rarity(): String return "common"; // Default rarity
    private function get_consumableType(): String return consumableEntity != null ? consumableEntity.effectId : "";
    private function get_effectValue(): Float return 10.0; // Default effect value
    
    /**
     * Reset for reuse
     */
    override public function reset(): Void {
        super.reset();
        glowIntensity = 0.0;
        pulsePhase = 0.0;
    }
}
