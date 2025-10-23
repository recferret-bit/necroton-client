package engine.model.entities;

import engine.model.EntityType;
import engine.model.entities.base.EngineEntitySpec;

/**
 * EntitySpecs - Entity specification seed data for the engine
 * Provides standardized entity specifications for different types
 * Migrated and enhanced from AcolyteSpecs.hx
 */
class EngineEntitySpecs {
    
    /**
     * Get player character spec
     */
    public static function getPlayerCharacterSpec(): EngineEntitySpec {
        return {
            type: EntityType.CHARACTER,
            pos: {x: 100, y: 100},
            ownerId: "player1",
            level: 1,
            maxHp: 100,
            hp: 100,
            stats: {
                speed: 8,
                power: 25,
                armor: 15,
                castSpeed: 1
            },
            attackDefs: [],
            spellBook: [],
            aiProfile: "player"
        };
    }
    
    /**
     * Get idle acolyte spec
     */
    public static function getIdleAcolyteSpec(): EngineEntitySpec {
        return {
            type: EntityType.CHARACTER,
            pos: {x: 150, y: 100},
            ownerId: "ai",
            level: 1,
            maxHp: 80,
            hp: 80,
            stats: {
                speed: 8,
                power: 20,
                armor: 10,
                castSpeed: 1
            },
            attackDefs: [],
            spellBook: [],
            aiProfile: "idle"
        };
    }
    
    /**
     * Get monster spec
     */
    public static function getMonsterSpec(): EngineEntitySpec {
        return {
            type: EntityType.CHARACTER,
            pos: {x: 200, y: 200},
            ownerId: "ai",
            level: 1,
            maxHp: 50,
            hp: 50,
            stats: {
                speed: 8,
                power: 15,
                armor: 5,
                castSpeed: 1
            },
            attackDefs: [],
            spellBook: [],
            aiProfile: "aggressive"
        };
    }
    
    /**
     * Get health potion consumable spec
     */
    public static function getHealthPotionSpec(): EngineEntitySpec {
        return {
            type: EntityType.CONSUMABLE,
            pos: {x: 250, y: 150},
            ownerId: "world",
            consumableType: "health_potion",
            quantity: 1,
            effectValue: 25
        };
    }
    
    /**
     * Get mana potion consumable spec
     */
    public static function getManaPotionSpec(): EngineEntitySpec {
        return {
            type: EntityType.CONSUMABLE,
            pos: {x: 300, y: 150},
            ownerId: "world",
            consumableType: "mana_potion",
            quantity: 1,
            effectValue: 20
        };
    }
    
    /**
     * Get speed boost effect spec
     */
    public static function getSpeedBoostEffectSpec(): EngineEntitySpec {
        return {
            type: EntityType.EFFECT,
            pos: {x: 200, y: 100},
            ownerId: "world",
            effectType: "speed_boost",
            duration: 10,
            effectValue: 1.5
        };
    }
    
    /**
     * Get damage effect spec
     */
    public static function getDamageEffectSpec(): EngineEntitySpec {
        return {
            type: EntityType.EFFECT,
            pos: {x: 250, y: 200},
            ownerId: "world",
            effectType: "damage",
            duration: 2,
            effectValue: 10,
        };
    }
    
    /**
     * Get spawn positions for different entity types
     */
    public static function getSpawnPositions(): {
        player: Array<{x: Int, y: Int}>,
        acolytes: Array<{x: Int, y: Int}>,
        monsters: Array<{x: Int, y: Int}>,
        consumables: Array<{x: Int, y: Int}>,
        effects: Array<{x: Int, y: Int}>
    } {
        return {
            player: [
                { x: 100, y: 100 }
            ],
            acolytes: [
                { x: 150, y: 100 },
                { x: 120, y: 150 }
            ],
            monsters: [
                { x: 200, y: 200 },
                { x: 300, y: 150 },
                { x: 250, y: 300 },
                { x: 180, y: 250 },
                { x: 320, y: 280 }
            ],
            consumables: [
                { x: 250, y: 150 },
                { x: 300, y: 150 },
                { x: 350, y: 200 }
            ],
            effects: [
                { x: 200, y: 100 },
                { x: 250, y: 200 }
            ]
        };
    }
    
    /**
     * Get collider spec
     */
    public static function getColliderSpec(x: Int, y: Int, passable: Bool, isTrigger: Bool): EngineEntitySpec {
        return {
            type: EntityType.COLLIDER,
            pos: {x: x, y: y},
            ownerId: "world",
            isAlive: true,  // explicitly set colliders as alive
            passable: passable,
            isTrigger: isTrigger,
            colliderWidth: 2,  // reasonable size for collision
            colliderHeight: 2  // reasonable size for collision
        };
    }
    
    /**
     * Generate map colliders in chess pattern
     * @param rows Number of rows
     * @param cols Number of columns
     * @return Array of collider specs
     */
    public static function generateMapColliders(rows: Int, cols: Int): Array<EngineEntitySpec> {
        final colliders = [];
        final spacing = 10 * NecrotonEngine.Config.unitPixels; // 10 units between each collider
        
        for (row in 0...rows) {
            for (col in 0...cols) {
                final x = col * spacing;
                final y = row * spacing;
                
                // Chess pattern: alternate passable/impassable
                final passable = (row + col) % 2 == 0;
                final isTrigger = false; // No triggers in basic map
                
                colliders.push(getColliderSpec(x, y, passable, isTrigger));
            }
        }
        
        return colliders;
    }
    
    /**
     * Get entity spec by type and index
     */
    public static function getEntitySpec(type: EntityType, index: Int = 0): EngineEntitySpec {
        switch (type) {
            case CHARACTER:
                switch (index) {
                    case 0: return getPlayerCharacterSpec();
                    case 1: return getIdleAcolyteSpec();
                    default: return getMonsterSpec();
                }
            case CONSUMABLE:
                switch (index) {
                    case 0: return getHealthPotionSpec();
                    case 1: return getManaPotionSpec();
                    default: return getHealthPotionSpec();
                }
            case EFFECT:
                switch (index) {
                    case 0: return getSpeedBoostEffectSpec();
                    case 1: return getDamageEffectSpec();
                    default: return getSpeedBoostEffectSpec();
                }
            case COLLIDER:
                return getColliderSpec(0, 0, false, false);
            default:
                return getPlayerCharacterSpec();
        }
    }
}
