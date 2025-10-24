package game.mvp.view.camera;

/**
 * Camera smoothing modes
 */
enum CameraSmoothingMode {
    LERP;                    // Linear interpolation with factor 0-1
    TIME_BASED_DAMPING;      // Time-based damping in seconds
}
