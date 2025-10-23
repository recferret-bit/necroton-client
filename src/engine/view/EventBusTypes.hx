package engine.view;

import engine.geometry.Vec2;
import engine.model.EntityType;

/**
 * Event type definitions for the event bus
 * Consolidates all event schemas in one place
 */
class EventBusTypes {
    
    // Entity Events
    public static inline var ENTITY_SPAWN = "entity:spawn";
    public static inline var ENTITY_DEATH = "entity:death";
    public static inline var ENTITY_MOVE = "entity:move";
    public static inline var ENTITY_CORRECTION = "entity:correction";
    public static inline var ENTITY_DAMAGE = "entity:damage";
    public static inline var ENTITY_COLLISION = "entity:collision";
    
    // Tick Events
    public static inline var TICK_COMPLETE = "tick:complete";
    
    // Snapshot Events
    public static inline var SNAPSHOT = "snapshot";
    
    // Physics Events
    public static inline var PHYSICS_CONTACT = "physics:contact";
    
    // Action Events
    public static inline var ACTION_INTENT = "action:intent";
    public static inline var ACTION_RESOLVED = "action:resolved";
}

/**
 * Event payload type definitions
 */
typedef EntitySpawnEvent = {
    var tick: Int;
    var entityId: Int;
    var type: EntityType;
    var pos: Vec2;
    var ownerId: String;
}

typedef EntityMoveEvent = {
    var tick: Int;
    var entityId: Int;
    var pos: Vec2;
    var vel: Vec2;
    var rotation: Float;
}

typedef EntityDamageEvent = {
    var tick: Int;
    var entityId: Int;
    var damage: Int;
    var attackerId: Int;
    var newHp: Int;
}

typedef EntityDeathEvent = {
    var tick: Int;
    var entityId: Int;
    var killerId: Int;
}

typedef EntityCollisionEvent = {
    var tick: Int;
    var entityIdA: Int;
    var entityIdB: Int;
    var contactPoint: Vec2;
    var normal: Vec2;
}

typedef EntityCorrectionEvent = {
    var tick: Int;
    var entityId: Int;
    var correctedPos: Vec2;
    var correctedVel: Vec2;
}

typedef ActionIntentEvent = {
    var tick: Int;
    var actorId: Int;
    var actionType: String;
    var target: Dynamic;
}

typedef ActionResolvedEvent = {
    var tick: Int;
    var actorId: Int;
    var actionType: String;
    var result: Dynamic;
}

typedef TickCompleteEvent = {
    var tick: Int;
}

typedef SnapshotEvent = {
    var tick: Int;
    var serializedState: Dynamic;
}

typedef ColliderTriggerEvent = {
    var tick: Int;
    var entityId: Int;
    var colliderId: Int;
    var triggerPos: Vec2;
}