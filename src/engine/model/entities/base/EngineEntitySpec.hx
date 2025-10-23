package engine.model.entities.base;

import engine.model.EntityType;

/**
 * Entity specification type definitions for type-safe entity creation
 * 
 * Provides strongly-typed specifications for different entity types,
 * replacing Dynamic spec parameters with compile-time type safety.
 */

/**
 * Base entity specification with common fields
 */
typedef EngineEntitySpec = {
    ?id: Int,
    ?type: EntityType,
    pos: {x: Int, y: Int},
    ?vel: {x: Int, y: Int},
    ?rotation: Float,
    ownerId: String,
    ?isAlive: Bool,
    ?isInputDriven: Bool,
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    // Character fields
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: {power: Int, armor: Int, speed: Int, castSpeed: Int},
    ?attackDefs: Array<Dynamic>,
    ?spellBook: Array<Dynamic>,
    ?aiProfile: String,
    // Consumable fields
    ?effectId: String,
    ?durationTicks: Int,
    ?stackable: Bool,
    ?charges: Int,
    ?useRange: Int,
    ?consumableType: String,
    ?quantity: Int,
    ?effectValue: Dynamic, // Can be Int or Float depending on context
    // Effect fields
    ?effectType: String,
    ?intensity: Int,
    ?targetId: Int,
    ?casterId: Int,
    ?duration: Int,
    // Collider fields
    ?passable: Bool,
    ?isTrigger: Bool
}