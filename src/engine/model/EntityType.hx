package engine.model;

/**
 * Entity type definitions as abstract string enum
 */
enum abstract EntityType(String) from String to String {
    var CHARACTER = "character";
    var CONSUMABLE = "consumable";
    var EFFECT = "effect";
    var COLLIDER = "collider";
    var GENERIC = "generic";
}
