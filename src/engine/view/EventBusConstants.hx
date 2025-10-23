package engine.view;

/**
 * Event constants for the event bus
 * These constants can be used in both Haxe and TypeScript
 * Provides a centralized location for all event string constants
 */
class EventBusConstants {
    // Entity events
    public static inline final ENTITY_SPAWN = "entity:spawn";
    public static inline final ENTITY_DEATH = "entity:death";
    public static inline final ENTITY_MOVE = "entity:move";
    public static inline final ENTITY_CORRECTION = "entity:correction";
    public static inline final ENTITY_DAMAGE = "entity:damage";
    public static inline final ENTITY_COLLISION = "entity:collision";
    
    // Tick events
    public static inline final TICK_COMPLETE = "tick:complete";
    
    // Snapshot events
    public static inline final SNAPSHOT = "snapshot";
    
    // Physics events
    public static inline final PHYSICS_CONTACT = "physics:contact";
    
    // Collider events
    public static inline final COLLIDER_TRIGGER = "collider:trigger";
    
    // Action events
    public static inline final ACTION_INTENT = "action:intent";
    public static inline final ACTION_RESOLVED = "action:resolved";
}
