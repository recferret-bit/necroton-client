package game.mvp.model.entities;

import engine.model.entities.impl.EngineCharacterEntity;

/**
 * Character entity model extending BaseEntityModel
 * Wraps engine CharacterEntity with visual metadata
 */
class CharacterModel extends BaseEntityModel {
    // Reference to engine character entity
    public var characterEntity(get, never): EngineCharacterEntity;
    
    // Visual state
    public var isMoving: Bool;
    public var lastMoveTime: Float;
    
    public function new() {
        super();
        
        isMoving = false;
        lastMoveTime = 0;
    }
    
    private function get_characterEntity(): EngineCharacterEntity {
        return cast(engineEntity, EngineCharacterEntity);
    }
    
    /**
     * Initialize with engine character entity
     */
    // public function initializeCharacter(characterEntity: CharacterEntity): Void {
    //     super.initialize(characterEntity);
    // }
    
    /**
     * Update character state from engine
     */
    override public function updateFromEngine(): Void {
        super.updateFromEngine();
        
        if (characterEntity == null) return;
        
        // Track previous position for interpolation
        if (previousPos.x != characterEntity.pos.x || previousPos.y != characterEntity.pos.y) {
            previousPos.x = renderPos.x;  // Store current render pos as previous
            previousPos.y = renderPos.y;
            interpolationAlpha = 0.0;  // Reset interpolation
        }
        
        // Smooth interpolation towards target
        var interpSpeed = 0.3;  // Tune this (0.0-1.0, higher = faster)
        interpolationAlpha = Math.min(1.0, interpolationAlpha + interpSpeed);
        
        renderPos.x = Std.int(previousPos.x + (characterEntity.pos.x - previousPos.x) * interpolationAlpha);
        renderPos.y = Std.int(previousPos.y + (characterEntity.pos.y - previousPos.y) * interpolationAlpha);
        
        // Update movement state based on velocity or position changes
        var speed = Math.sqrt(vel.x * vel.x + vel.y * vel.y);
        isMoving = speed > 0.1;
        if (isMoving) {
            lastMoveTime = 0; // Reset when moving
        } else {
            lastMoveTime += 0.016; // Approximate frame time
        }
    }
    
    
    /**
     * Take damage
     */
    public function takeDamage(damage: Int): Void {
        if (characterEntity != null) {
            characterEntity.hp = Std.int(Math.max(0, characterEntity.hp - damage));
            needsVisualUpdate = true;
        }
    }
    
    /**
     * Heal
     */
    public function heal(amount: Int): Void {
        if (characterEntity != null) {
            characterEntity.hp = Std.int(Math.min(characterEntity.maxHp, characterEntity.hp + amount));
            needsVisualUpdate = true;
        }
    }
    
    /**
     * Check if character is dead
     */
    public function isDead(): Bool {
        return characterEntity != null ? (characterEntity.hp <= 0 || !isAlive) : true;
    }
    
    /**
     * Get health percentage (0.0 to 1.0)
     */
    public function getHealthPercentage(): Float {
        if (characterEntity == null) return 0.0;
        return characterEntity.maxHp > 0 ? characterEntity.hp / characterEntity.maxHp : 0.0;
    }
    
    // Convenience getters that delegate to character entity
    public var maxHp(get, never): Int;
    public var hp(get, never): Int;
    public var level(get, never): Int;
    public var stats(get, never): Dynamic;
    public var attackDefs(get, never): Array<Dynamic>;
    public var spellBook(get, never): Array<Dynamic>;
    public var aiProfile(get, never): String;
    
    private function get_maxHp(): Int return characterEntity != null ? characterEntity.maxHp : 0;
    private function get_hp(): Int return characterEntity != null ? characterEntity.hp : 0;
    private function get_level(): Int return characterEntity != null ? characterEntity.level : 0;
    private function get_stats(): Dynamic return characterEntity != null ? characterEntity.stats : {};
    private function get_attackDefs(): Array<Dynamic> return characterEntity != null ? characterEntity.attackDefs : [];
    private function get_spellBook(): Array<Dynamic> return characterEntity != null ? characterEntity.spellBook : [];
    private function get_aiProfile(): String return characterEntity != null ? characterEntity.aiProfile : "";
    
    /**
     * Reset for reuse
     */
    override public function reset(): Void {
        super.reset();
        isMoving = false;
        lastMoveTime = 0;
    }
    
    /**
     * Get character model
     */
    public function getCharacterModel(): CharacterModel {
        return this;
    }
}

