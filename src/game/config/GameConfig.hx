package game.config;

class GameConfig {
    // World scale (from docs/5-game-units.md - Option A)
    public static var viewportWidthUnits:Float = 160.0;  // World units visible
    public static var pixelsPerUnit:Float = 6.75;         // px/unit (for 1080px device)
    public static var deviceWidth:Float = 1080.0;         // Target device width
    
    // Derived viewport height (16:9 aspect ratio)
    public static var viewportHeightUnits:Float = 90.0;  // 160 * (9/16) = 90 units
    
    // Entity sizes (in world units)
    public static var playerRadius:Float = 0.5;           // Player collision radius
    public static var acolyteRadius:Float = 0.5;          // AI acolyte radius
    public static var monsterRadius:Float = 0.8;          // Monster radius
    
    // Visual sizes (in pixels on screen)
    public static var characterHeight:Float = 80.0;       // Character visual height ~80px
    
    // Debug rendering
    public static var drawPhysicsShapes:Bool = true;
    public static var drawHealthBars:Bool = true;
    
    // Colors
    public static var colorAcolyte:Int = 0x0088FF;        // Blue
    public static var colorLich:Int = 0x00FF00;           // Green
    public static var colorMonster:Int = 0xFF0000;        // Red
    public static var colorPhysicsShape:Int = 0xFFFF00;   // Yellow (debug)
    
    // Helper methods
    public static function worldToPixels(worldUnits:Float):Float {
        return worldUnits * pixelsPerUnit;
    }
    
    public static function pixelsToWorld(pixels:Float):Float {
        return pixels / pixelsPerUnit;
    }
}
