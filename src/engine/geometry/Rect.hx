package engine.geometry;

/**
 * 2D Rectangle with center position and dimensions
 * Used for axis-aligned bounding box (AABB) collision detection
 */
typedef Rect = {
    var x: Float;      // Center X position
    var y: Float;      // Center Y position
    var width: Float;  // Width in units
    var height: Float; // Height in units
}
