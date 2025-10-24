package game.mvp.model.entities;

import engine.model.entities.EntityType;
import engine.model.entities.impl.EngineEffectEntity;

/**
 * Effect entity model extending BaseEntityModel
 * Wraps engine EffectEntity with visual metadata
 */
class EffectModel extends BaseEntityModel {
    // Reference to engine effect entity
    public var effectEntity(get, never): EngineEffectEntity;
    
    // Visual state
    public var particleCount: Int;
    public var animationPhase: Float;
    public var intensity: Float;
    
    public function new() {
        super();
        
        particleCount = 5;
        animationPhase = 0.0;
        intensity = 1.0;
    }
    
    private function get_effectEntity(): EngineEffectEntity {
        return cast(engineEntity, EngineEffectEntity);
    }
    
    /**
     * Initialize with engine effect entity
     */
    public function initializeEffect(effectEntity: EngineEffectEntity): Void {
        super.initialize(effectEntity);
        setEffectVisuals();
    }
    
    /**
     * Set visual properties based on effect type
     */
    private function setEffectVisuals(): Void {
        if (effectEntity == null) return;
        
        switch (effectEntity.effectType) {
            case "damage":
                color = 0xFF0000;  // Red
                particleCount = 8;
            case "heal":
                color = 0x00FF00;  // Green
                particleCount = 6;
            case "speed_boost":
                color = 0x00FFFF;  // Cyan
                particleCount = 4;
            case "shield":
                color = 0x0000FF;  // Blue
                particleCount = 10;
            default:
                color = 0xFF00FF;  // Magenta
                particleCount = 5;
        }
    }
    
    /**
     * Update effect state
     */
    public function update(dt: Float): Void {
        if (effectEntity == null) return;
        
        // Update animation
        animationPhase += dt * 4.0; // 4 cycles per second
        if (animationPhase > Math.PI * 2) {
            animationPhase -= Math.PI * 2;
        }
        
        // Update intensity based on remaining duration
        intensity = getDurationPercentage();
        
        // Update visual scale based on animation
        var animScale = 1.0 + Math.sin(animationPhase) * 0.2 * intensity;
        visualScale = animScale;
        
        needsVisualUpdate = true;
    }
    
    /**
     * Check if effect is expired
     */
    public function isExpired(): Bool {
        return effectEntity != null ? (effectEntity.durationTicks <= 0 || !isAlive) : true;
    }
    
    /**
     * Get remaining duration percentage (0.0 to 1.0)
     */
    public function getDurationPercentage(): Float {
        if (effectEntity == null) return 0.0;
        // Convert ticks to percentage (assuming 60 ticks per second)
        var maxDurationTicks = effectEntity.durationTicks * 60; // Convert to ticks
        return maxDurationTicks > 0 ? effectEntity.durationTicks / maxDurationTicks : 0.0;
    }
    
    /**
     * Get effect description
     */
    public function getEffectDescription(): String {
        if (effectEntity == null) return "Unknown effect";
        
        switch (effectEntity.effectType) {
            case "damage":
                return "Deals damage over time";
            case "heal":
                return "Heals over time";
            case "speed_boost":
                return "Increases speed";
            case "shield":
                return "Provides damage absorption";
            default:
                return "Unknown effect";
        }
    }
    
    /**
     * Apply effect to target (called by game logic)
     */
    public function applyEffect(): Float {
        return effectEntity != null ? effectEntity.intensity : 0.0;
    }
    
    // Convenience getters that delegate to effect entity
    public var effectType(get, never): String;
    public var durationTicks(get, never): Int;
    public var effectIntensity(get, never): Float;
    public var targetId(get, never): Int;
    public var casterId(get, never): Int;
    public var duration(get, never): Float;
    
    private function get_effectType(): String return effectEntity != null ? effectEntity.effectType : "";
    private function get_durationTicks(): Int return effectEntity != null ? effectEntity.durationTicks : 0;
    private function get_effectIntensity(): Float return effectEntity != null ? effectEntity.intensity : 0.0;
    private function get_targetId(): Int return effectEntity != null ? effectEntity.targetId : 0;
    private function get_casterId(): Int return effectEntity != null ? effectEntity.casterId : 0;
    private function get_duration(): Float return effectEntity != null ? effectEntity.durationTicks / 60.0 : 0.0; // Convert ticks to seconds
    
    /**
     * Reset for reuse
     */
    override public function reset(): Void {
        super.reset();
        particleCount = 5;
        animationPhase = 0.0;
        intensity = 1.0;
    }
}
