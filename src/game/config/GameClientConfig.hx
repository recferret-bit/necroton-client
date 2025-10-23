package game.config;

import engine.EngineConfig;

/**
 * Game client configuration wrapper around EngineConfig
 * Provides game-specific settings and visual configuration
 */
class GameClientConfig {
    public var engineConfig: EngineConfig;
    public var gameMode: GameMode;
    public var visualSettings: VisualSettings;
    
    public function new() {
        // Default visual settings
        visualSettings = new VisualSettings();
        
        // Default engine config
        engineConfig = {
            mode: SINGLEPLAYER,
            tickRate: 60,
            unitPixels: 32,
            aiUpdateInterval: 10,
            snapshotBufferSize: 1000,
            rngSeed: 12345,
            snapshotEmissionInterval: 5
        };
        
        gameMode = SINGLEPLAYER;
    }
    
    /**
     * Create config for singleplayer mode
     */
    public static function createSingleplayer(): GameClientConfig {
        var config = new GameClientConfig();
        config.gameMode = SINGLEPLAYER;
        config.engineConfig.mode = SINGLEPLAYER;
        return config;
    }
    
    /**
     * Create config for server mode
     */
    public static function createServer(): GameClientConfig {
        var config = new GameClientConfig();
        config.gameMode = SERVER;
        config.engineConfig.mode = SERVER;
        return config;
    }
    
    /**
     * Create config for client prediction mode
     */
    public static function createClientPrediction(): GameClientConfig {
        var config = new GameClientConfig();
        config.gameMode = CLIENT_PREDICTION;
        config.engineConfig.mode = CLIENT_PREDICTION;
        return config;
    }
}

/**
 * Game mode enumeration
 */
enum GameMode {
    SINGLEPLAYER;
    SERVER;
    CLIENT_PREDICTION;
}

/**
 * Visual settings for rendering
 */
class VisualSettings {
    public var pixelsPerUnit: Float;
    public var viewportWidthUnits: Float;
    public var viewportHeightUnits: Float;
    public var characterHeight: Float;
    public var drawPhysicsShapes: Bool;
    public var drawHealthBars: Bool;
    
    // Entity colors
    public var colorPlayer: Int;
    public var colorAcolyte: Int;
    public var colorMonster: Int;
    public var colorConsumable: Int;
    public var colorEffect: Int;
    public var colorPhysicsShape: Int;
    
    public function new() {
        // Use values from GameConfig
        pixelsPerUnit = 6.75;
        viewportWidthUnits = 160.0;
        viewportHeightUnits = 90.0;
        characterHeight = 80.0;
        drawPhysicsShapes = true;
        drawHealthBars = true;
        
        // Default colors
        colorPlayer = 0x00FF00;      // Green
        colorAcolyte = 0x0088FF;     // Blue
        colorMonster = 0xFF0000;     // Red
        colorConsumable = 0xFFFF00;  // Yellow
        colorEffect = 0xFF00FF;      // Magenta
        colorPhysicsShape = 0xFFFF00; // Yellow (debug)
    }
    
    /**
     * Convert world units to pixels
     */
    public function worldToPixels(worldUnits: Float): Float {
        return worldUnits * pixelsPerUnit;
    }
    
    /**
     * Convert pixels to world units
     */
    public function pixelsToWorld(pixels: Float): Float {
        return pixels / pixelsPerUnit;
    }
}
