package game.mvp.view.entities;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Graphics;
import game.mvp.model.entities.EffectModel;
import game.mvp.model.entities.BaseEntityModel;

/**
 * Effect entity view extending BaseGameEntityView
 * Adds effect-specific visual features like particles and duration indicators
 */
class EffectEntityView extends BaseGameEntityView {
    // Effect-specific visual components
    private var particleSystem: Graphics;
    private var durationBar: Graphics;
    private var effectText: h2d.Text;
    
    // Visual state
    private var particles: Array<Particle>;
    private var showDuration: Bool;
    private var showEffectName: Bool;
    private var animationPhase: Float;
    
    public function new(parent: Object = null) {
        super(parent);
        
        // Initialize effect-specific properties
        showDuration = true;
        showEffectName = false;
        animationPhase = 0.0;
        particles = [];
    }
    
    /**
     * Initialize effect view
     */
    override public function initialize(model: BaseEntityModel): Void {
        super.initialize(model);
        
        // Create effect-specific visuals
        createEffectVisuals();
    }
    
    /**
     * Create effect-specific visual elements
     */
    private function createEffectVisuals(): Void {
        var effectModel = cast(model, EffectModel);
        if (effectModel == null) return;
        
        // Create particle system
        createParticleSystem();
        
        // Create duration bar
        if (showDuration) {
            createDurationBar();
        }
        
        // Create effect name text
        if (showEffectName) {
            createEffectText();
        }
    }
    
    /**
     * Create particle system for effects
     */
    private function createParticleSystem(): Void {
        if (particleSystem != null) {
            particleSystem.remove();
        }
        
        particleSystem = new Graphics(this);
        var effectModel = cast(model, EffectModel);
        if (effectModel == null) return;
        
        // Initialize particles based on effect type
        initializeParticles(effectModel);
    }
    
    /**
     * Initialize particles based on effect type
     */
    private function initializeParticles(effectModel: EffectModel): Void {
        particles = [];
        
        for (i in 0...effectModel.particleCount) {
            var particle = new Particle();
            particle.x = (Math.random() - 0.5) * Math.max(model.colliderWidth, model.colliderHeight) * 10;
            particle.y = (Math.random() - 0.5) * Math.max(model.colliderWidth, model.colliderHeight) * 10;
            particle.vx = (Math.random() - 0.5) * 50;
            particle.vy = (Math.random() - 0.5) * 50;
            particle.life = Math.random() * 2.0 + 1.0;
            particle.maxLife = particle.life;
            particle.size = Math.random() * 3 + 1;
            particle.color = model.color;
            particles.push(particle);
        }
    }
    
    /**
     * Create duration bar
     */
    private function createDurationBar(): Void {
        if (durationBar != null) {
            durationBar.remove();
        }
        
        durationBar = new Graphics(this);
    }
    
    /**
     * Create effect name text
     */
    private function createEffectText(): Void {
        if (effectText != null) {
            effectText.remove();
        }
        
        var effectModel = cast(model, EffectModel);
        if (effectModel == null) return;
        
        effectText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        effectText.text = effectModel.effectType;
        effectText.textColor = 0xFFFFFF;
        effectText.x = -effectText.textWidth * 0.5;
        effectText.y = -model.colliderHeight * 8 - 20;
    }
    
    /**
     * Update effect view
     */
    override public function update(): Void {
        super.update();
        
        if (!isInitialized || model == null || !model.isAlive) {
            return;
        }
        
        var effectModel = cast(model, EffectModel);
        if (effectModel == null) return;
        
        // Update effect-specific visuals
        updateEffectVisuals(effectModel);
    }
    
    /**
     * Update effect-specific visual elements
     */
    private function updateEffectVisuals(effectModel: EffectModel): Void {
        // Update animation phase
        animationPhase += 0.1;
        if (animationPhase > Math.PI * 2) {
            animationPhase -= Math.PI * 2;
        }
        
        // Update particles
        updateParticles(effectModel);
        
        // Update duration bar
        updateDurationBar(effectModel);
        
        // Update effect text
        if (effectText != null) {
            effectText.text = effectModel.effectType + " (" + Std.int(effectModel.duration) + "s)";
        }
    }
    
    /**
     * Update particle system
     */
    private function updateParticles(effectModel: EffectModel): Void {
        if (particleSystem == null) return;
        
        // Update existing particles
        for (particle in particles) {
            particle.x += particle.vx * 0.016;
            particle.y += particle.vy * 0.016;
            particle.life -= 0.016;
            
            // Apply gravity or other forces based on effect type
            switch (effectModel.effectType) {
                case "damage":
                    // Particles move outward
                    particle.vx *= 1.02;
                    particle.vy *= 1.02;
                case "heal":
                    // Particles move upward
                    particle.vy -= 10;
                case "speed_boost":
                    // Particles spiral
                    var angle = Math.atan2(particle.y, particle.x) + 0.1;
                    var radius = Math.sqrt(particle.x * particle.x + particle.y * particle.y);
                    particle.x = Math.cos(angle) * radius;
                    particle.y = Math.sin(angle) * radius;
                default:
                    // Default behavior
            }
        }
        
        // Remove dead particles
        particles = particles.filter(function(particle) {
            return particle.life > 0;
        });
        
        // Add new particles if needed
        while (particles.length < effectModel.particleCount) {
            var particle = new Particle();
            particle.x = (Math.random() - 0.5) * Math.max(model.colliderWidth, model.colliderHeight) * 10;
            particle.y = (Math.random() - 0.5) * Math.max(model.colliderWidth, model.colliderHeight) * 10;
            particle.vx = (Math.random() - 0.5) * 50;
            particle.vy = (Math.random() - 0.5) * 50;
            particle.life = Math.random() * 2.0 + 1.0;
            particle.maxLife = particle.life;
            particle.size = Math.random() * 3 + 1;
            particle.color = model.color;
            particles.push(particle);
        }
        
        // Render particles
        renderParticles();
    }
    
    /**
     * Render particle system
     */
    private function renderParticles(): Void {
        if (particleSystem == null) return;
        
        particleSystem.clear();
        
        for (particle in particles) {
            var alpha = particle.life / particle.maxLife;
            var size = particle.size * alpha;
            
            particleSystem.beginFill(particle.color, alpha);
            particleSystem.drawCircle(particle.x, particle.y, size);
            particleSystem.endFill();
        }
    }
    
    /**
     * Update duration bar
     */
    private function updateDurationBar(effectModel: EffectModel): Void {
        if (durationBar == null) return;
        
        var barWidth = 40;
        var barHeight = 3;
        var durationPercent = effectModel.getDurationPercentage();
        
        durationBar.clear();
        durationBar.x = -barWidth * 0.5;
        durationBar.y = -model.colliderHeight * 8 - 15;
        
        // Background (dark)
        durationBar.beginFill(0x333333);
        durationBar.drawRect(0, 0, barWidth, barHeight);
        durationBar.endFill();
        
        // Duration (color based on effect type)
        var barColor = getEffectColor(effectModel.effectType);
        durationBar.beginFill(barColor);
        durationBar.drawRect(0, 0, barWidth * durationPercent, barHeight);
        durationBar.endFill();
    }
    
    /**
     * Get color based on effect type
     */
    private function getEffectColor(effectType: String): Int {
        switch (effectType) {
            case "damage":
                return 0xFF0000;
            case "heal":
                return 0x00FF00;
            case "speed_boost":
                return 0x00FFFF;
            case "shield":
                return 0x0000FF;
            default:
                return 0xFF00FF;
        }
    }
    
    /**
     * Set duration visibility
     */
    public function setDurationVisible(visible: Bool): Void {
        showDuration = visible;
        if (durationBar != null) {
            durationBar.visible = visible;
        }
    }
    
    /**
     * Set effect name visibility
     */
    public function setEffectNameVisible(visible: Bool): Void {
        showEffectName = visible;
        if (effectText != null) {
            effectText.visible = visible;
        }
    }
    
    /**
     * Get effect model
     */
    public function getEffectModel(): EffectModel {
        return cast(model, EffectModel);
    }
    
    /**
     * Reset for object pooling
     */
    override public function reset(): Void {
        // Clear effect-specific visuals
        if (particleSystem != null) {
            particleSystem.remove();
            particleSystem = null;
        }
        
        if (durationBar != null) {
            durationBar.remove();
            durationBar = null;
        }
        
        if (effectText != null) {
            effectText.remove();
            effectText = null;
        }
        
        particles = [];
        animationPhase = 0.0;
        
        // Call parent reset
        super.reset();
    }
    
    /**
     * Destroy effect view
     */
    override public function destroy(): Void {
        if (particleSystem != null) {
            particleSystem.remove();
            particleSystem = null;
        }
        
        if (durationBar != null) {
            durationBar.remove();
            durationBar = null;
        }
        
        if (effectText != null) {
            effectText.remove();
            effectText = null;
        }
        
        particles = [];
        
        super.destroy();
    }
}

/**
 * Particle class for effect visuals
 */
class Particle {
    public var x: Float;
    public var y: Float;
    public var vx: Float;
    public var vy: Float;
    public var life: Float;
    public var maxLife: Float;
    public var size: Float;
    public var color: Int;
    
    public function new() {
        x = 0;
        y = 0;
        vx = 0;
        vy = 0;
        life = 1.0;
        maxLife = 1.0;
        size = 1.0;
        color = 0xFFFFFF;
    }
}
