package engine.model.entities.impl;

import engine.geometry.Vec2;
import engine.NecrotonEngine;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Character entity with combat stats and abilities
 */
class EngineCharacterEntity extends BaseEngineEntity {
    public var maxHp: Int;
    public var hp: Int;
    public var level: Int;

    // TODO replace by typings
    public var stats: Dynamic; // {power: Float, defense: Float, speed: Float}
    public var attackDefs: Array<Dynamic>;
    public var spellBook: Array<Dynamic>;
    public var aiProfile: String;
    
    public function new() {
        super();
    }
    
    // TODO replace by typings
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.maxHp = maxHp;
        base.hp = hp;
        base.level = level;
        base.stats = stats;
        base.attackDefs = attackDefs;
        base.spellBook = spellBook;
        base.aiProfile = aiProfile;
        return base;
    }
    
    // TODO replace by typings
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);

        maxHp = data.maxHp;
        hp = data.hp;
        level = data.level;
        stats = data.stats;
        attackDefs = data.attackDefs;
        spellBook = data.spellBook;
        aiProfile = data.aiProfile;
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);

        if (spec == null) {
            maxHp = 100;
            hp = maxHp;
            level = 1;
            stats = {};
            attackDefs = [];
            spellBook = [];
            aiProfile = "";
            
            // Character-specific collider dimensions (smaller than default)
            colliderWidth = 3;
            colliderHeight = 5;
            
            // Characters are input-driven by default
            isInputDriven = true;

            return;
        }

        maxHp = spec.maxHp != null ? spec.maxHp : 100;
        hp = spec.hp != null ? spec.hp : maxHp;
        level = spec.level != null ? spec.level : 1;
        stats = spec.stats != null ? spec.stats : {};
        attackDefs = spec.attackDefs != null ? spec.attackDefs : [];
        spellBook = spec.spellBook != null ? spec.spellBook : [];
        aiProfile = spec.aiProfile != null ? spec.aiProfile : "";
        
        // Character-specific collider dimensions (smaller than default)
        if (spec.colliderWidth == null) colliderWidth = 3;
        if (spec.colliderHeight == null) colliderHeight = 5;
        
        // Characters are input-driven by default
        isInputDriven = spec.isInputDriven != null ? spec.isInputDriven : true;
    }
    

    /**
     * Apply movement step to position
     * @param movementX Movement input X (-1 to 1)
     * @param movementY Movement input Y (-1 to 1)
     * @param dt Delta time
     */
    public function applyMovementStep(movementX: Float, movementY: Float, dt: Float): Void {
        final movementStep = calculateMovementStep(movementX, movementY, dt);
        // Apply movement step to position
        pos.x += movementStep.x;
        pos.y += movementStep.y;
                    
        // Clear velocity (movement is step-based, not continuous)
        vel.x = 0;
        vel.y = 0;
    }

    /**
     * Calculate movement step from input
     * @param movementX Movement input X (-1 to 1)
     * @param movementY Movement input Y (-1 to 1)
     * @param dt Delta time
     * @return Movement step {x: Int, y: Int}
     */
    public function calculateMovementStep(movementX: Float, movementY: Float, dt: Float): Vec2 {
        final speed = (stats != null && stats.speed != null ? stats.speed : 1.0) * NecrotonEngine.Config.unitPixels;
        return {
            x: Std.int(movementX * speed * dt),
            y: Std.int(movementY * speed * dt)
        };
    }
    
}
