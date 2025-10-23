package engine.geometry;

/**
 * Rectangle math utilities for collision detection and geometric operations
 */
class RectUtils {
    
    /**
     * Create a new rectangle
     */
    public static function create(x: Int, y: Int, width: Int, height: Int): Rect {
        return { x: x, y: y, width: width, height: height };
    }
    
    /**
     * Create rectangle from min/max bounds
     */
    public static function fromMinMax(minX: Int, minY: Int, maxX: Int, maxY: Int): Rect {
        return {
            x: (minX + maxX) / 2,
            y: (minY + maxY) / 2,
            width: maxX - minX,
            height: maxY - minY
        };
    }
    
    /**
     * Get bounding box as min/max coordinates
     */
    public static function getBounds(rect: Rect): {minX: Int, minY: Int, maxX: Int, maxY: Int} {
        final halfWidth = rect.width / 2;
        final halfHeight = rect.height / 2;
        return {
            minX: Std.int(rect.x - halfWidth),
            minY: Std.int(rect.y - halfHeight),
            maxX: Std.int(rect.x + halfWidth),
            maxY: Std.int(rect.y + halfHeight)
        };
    }
    
    /**
     * Check if point is inside rectangle
     */
    public static function contains(rect: Rect, point: Vec2): Bool {
        final bounds = getBounds(rect);
        return point.x >= bounds.minX && point.x <= bounds.maxX && 
               point.y >= bounds.minY && point.y <= bounds.maxY;
    }
    
    /**
     * Check if two rectangles intersect (AABB collision)
     */
    public static function intersectsRect(rectA: Rect, rectB: Rect): Bool {
        final boundsA = getBounds(rectA);
        final boundsB = getBounds(rectB);
        
        return boundsA.minX < boundsB.maxX && boundsA.maxX > boundsB.minX &&
               boundsA.minY < boundsB.maxY && boundsA.maxY > boundsB.minY;
    }
    
    /**
     * Check if rectangle intersects with line segment
     * Uses Liang-Barsky line clipping algorithm
     */
    public static function intersectsLine(rect: Rect, lineStart: Vec2, lineEnd: Vec2): Bool {
        final bounds = getBounds(rect);
        
        final dx = lineEnd.x - lineStart.x;
        final dy = lineEnd.y - lineStart.y;
        
        // Handle vertical and horizontal lines
        if (dx == 0) {
            return lineStart.x >= bounds.minX && lineStart.x <= bounds.maxX &&
                   ((lineStart.y >= bounds.minY && lineStart.y <= bounds.maxY) ||
                    (lineEnd.y >= bounds.minY && lineEnd.y <= bounds.maxY) ||
                    (lineStart.y < bounds.minY && lineEnd.y > bounds.maxY));
        }
        
        if (dy == 0) {
            return lineStart.y >= bounds.minY && lineStart.y <= bounds.maxY &&
                   ((lineStart.x >= bounds.minX && lineStart.x <= bounds.maxX) ||
                    (lineEnd.x >= bounds.minX && lineEnd.x <= bounds.maxX) ||
                    (lineStart.x < bounds.minX && lineEnd.x > bounds.maxX));
        }
        
        // Liang-Barsky algorithm
        var t0 = 0.0;
        var t1 = 1.0;
        
        final p = [-dx, dx, -dy, dy];
        final q = [lineStart.x - bounds.minX, bounds.maxX - lineStart.x, 
                 lineStart.y - bounds.minY, bounds.maxY - lineStart.y];
        
        for (i in 0...4) {
            if (p[i] == 0) {
                if (q[i] < 0) return false;
            } else {
                final t = q[i] / p[i];
                if (p[i] < 0) {
                    if (t > t1) return false;
                    if (t > t0) t0 = t;
                } else {
                    if (t < t0) return false;
                    if (t < t1) t1 = t;
                }
            }
        }
        
        return t0 <= t1;
    }
    
    /**
     * Check if rectangle intersects with circle
     * Uses closest point method
     */
    public static function intersectsCircle(rect: Rect, circleCenter: Vec2, radius: Float): Bool {
        final bounds = getBounds(rect);
        
        // Find closest point on rectangle to circle center
        final closestX = Math.max(bounds.minX, Math.min(circleCenter.x, bounds.maxX));
        final closestY = Math.max(bounds.minY, Math.min(circleCenter.y, bounds.maxY));
        
        // Calculate distance from circle center to closest point
        final dx = circleCenter.x - closestX;
        final dy = circleCenter.y - closestY;
        final distanceSquared = dx * dx + dy * dy;
        
        return distanceSquared <= radius * radius;
    }
    
    /**
     * Get intersection depth between two rectangles for collision resolution
     * Returns penetration vector (how much to separate)
     */
    public static function getIntersectionDepth(rectA: Rect, rectB: Rect): Vec2 {
        final boundsA = getBounds(rectA);
        final boundsB = getBounds(rectB);
        
        // Calculate overlap on each axis
        final overlapX = Math.min(boundsA.maxX, boundsB.maxX) - Math.max(boundsA.minX, boundsB.minX);
        final overlapY = Math.min(boundsA.maxY, boundsB.maxY) - Math.max(boundsA.minY, boundsB.minY);
        
        // Return the smaller overlap as separation vector
        if (overlapX < overlapY) {
            // Separate on X axis
            final direction = boundsA.minX < boundsB.minX ? -1 : 1;
            return { x: Std.int(overlapX * direction), y: 0 };
        } else {
            // Separate on Y axis
            final direction = boundsA.minY < boundsB.minY ? -1 : 1;
            return { x: 0, y: Std.int(overlapY * direction) };
        }
    }
    
    /**
     * Get rectangle area
     */
    public static function getArea(rect: Rect): Float {
        return rect.width * rect.height;
    }
    
    /**
     * Check if rectangle is valid (positive dimensions)
     */
    public static function isValid(rect: Rect): Bool {
        return rect.width > 0 && rect.height > 0;
    }
}
