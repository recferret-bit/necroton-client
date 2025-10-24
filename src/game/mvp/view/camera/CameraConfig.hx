package game.mvp.view.camera;

/**
 * Camera configuration data
 * Controls camera behavior and smoothing settings
 */
class CameraConfig {
    // Basic settings
    public var enabled: Bool;
    
    // Smoothing configuration
    public var smoothingMode: CameraSmoothingMode;
    public var smoothingValue: Float;
    
    // Viewport offset (camera offset from target position)
    public var viewportOffsetX: Float;
    public var viewportOffsetY: Float;
    
    public function new() {
        // Default configuration
        enabled = true;
        smoothingMode = LERP;
        smoothingValue = 0.15;  // Default lerp factor for smooth following
        viewportOffsetX = 0.0;
        viewportOffsetY = 0.0;
    }
    
    /**
     * Create config with custom smoothing
     */
    public static function createLerpConfig(lerpFactor: Float): CameraConfig {
        var config = new CameraConfig();
        config.smoothingMode = LERP;
        config.smoothingValue = lerpFactor;
        return config;
    }
    
    /**
     * Create config with time-based damping
     */
    public static function createDampingConfig(dampingTime: Float): CameraConfig {
        var config = new CameraConfig();
        config.smoothingMode = TIME_BASED_DAMPING;
        config.smoothingValue = dampingTime;
        return config;
    }
    
    /**
     * Create config for instant following (no smoothing)
     */
    public static function createInstantConfig(): CameraConfig {
        var config = new CameraConfig();
        config.smoothingMode = LERP;
        config.smoothingValue = 0.0;
        return config;
    }
    
    /**
     * Set viewport offset
     */
    public function setViewportOffset(offsetX: Float, offsetY: Float): CameraConfig {
        viewportOffsetX = offsetX;
        viewportOffsetY = offsetY;
        return this;
    }
    
    /**
     * Set smoothing mode and value
     */
    public function setSmoothing(mode: CameraSmoothingMode, value: Float): CameraConfig {
        smoothingMode = mode;
        smoothingValue = value;
        return this;
    }
    
    /**
     * Enable or disable camera
     */
    public function setEnabled(enabled: Bool): CameraConfig {
        this.enabled = enabled;
        return this;
    }
}
