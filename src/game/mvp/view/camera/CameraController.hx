package game.mvp.view.camera;

import game.mvp.model.GameClientState;
import game.mvp.model.entities.BaseEntityModel;
import h2d.Scene;

/**
 * Camera controller for smooth entity following
 * Supports dual smoothing modes and target switching for spectator mode
 */
class CameraController {
    // Core references
    private var scene: Scene;
    private var gameClientState: GameClientState;
    private var config: CameraConfig;
    
    // Following state
    private var targetEntityId: Null<Int>;
    private var isFollowing: Bool;
    
    // Current camera position
    private var currentX: Float;
    private var currentY: Float;
    
    // Smoothing state for time-based damping
    private var velocityX: Float;
    private var velocityY: Float;
    
    public function new(scene: Scene, gameClientState: GameClientState, config: CameraConfig) {
        this.scene = scene;
        this.gameClientState = gameClientState;
        this.config = config;
        
        // Initialize state
        targetEntityId = null;
        isFollowing = false;
        currentX = scene.camera.x;
        currentY = scene.camera.y;
        velocityX = 0.0;
        velocityY = 0.0;
    }
    
    /**
     * Update camera position
     * Call this every frame
     */
    public function update(dt: Float): Void {
        if (!config.enabled) return;
        
        if (isFollowing && targetEntityId != null) {
            var targetEntity = gameClientState.getEntity(targetEntityId);
            if (targetEntity != null && targetEntity.isAlive) {
                updateCameraToTarget(targetEntity, dt);
            }
        }
    }
    
    /**
     * Start following an entity by ID
     */
    public function followEntity(entityId: Int): Void {
        targetEntityId = entityId;
        isFollowing = true;
        
        // Immediately snap to target if entity exists
        var targetEntity = gameClientState.getEntity(entityId);
        if (targetEntity != null && targetEntity.isAlive) {
            var targetPos = getTargetPosition(targetEntity);
            setCameraPosition(targetPos.x, targetPos.y);
        }
    }
    
    /**
     * Stop following any entity
     */
    public function stopFollowing(): Void {
        isFollowing = false;
        targetEntityId = null;
    }
    
    /**
     * Set camera smoothing value
     */
    public function setFollowSmoothing(value: Float): Void {
        config.smoothingValue = value;
    }
    
    /**
     * Set smoothing mode
     */
    public function setSmoothingMode(mode: CameraSmoothingMode): Void {
        config.smoothingMode = mode;
    }
    
    /**
     * Get current camera position
     */
    public function getCameraPosition(): {x: Float, y: Float} {
        return {x: currentX, y: currentY};
    }
    
    /**
     * Set camera position directly
     */
    public function setCameraPosition(x: Float, y: Float): Void {
        currentX = x;
        currentY = y;
        scene.camera.x = x;
        scene.camera.y = y;
    }
    
    /**
     * Get currently followed entity ID
     */
    public function getTargetEntityId(): Null<Int> {
        return targetEntityId;
    }
    
    /**
     * Check if camera is following an entity
     */
    public function isFollowingEntity(): Bool {
        return isFollowing && targetEntityId != null;
    }
    
    /**
     * Update camera position to follow target entity
     */
    private function updateCameraToTarget(targetEntity: BaseEntityModel, dt: Float): Void {
        var targetPos = getTargetPosition(targetEntity);
        var targetX = targetPos.x;
        var targetY = targetPos.y;
        
        switch (config.smoothingMode) {
            case LERP:
                updateCameraLerp(targetX, targetY, dt);
            case TIME_BASED_DAMPING:
                updateCameraDamping(targetX, targetY, dt);
        }
    }
    
    /**
     * Update camera using linear interpolation
     */
    private function updateCameraLerp(targetX: Float, targetY: Float, dt: Float): Void {
        var lerpFactor = config.smoothingValue;
        
        // Apply lerp
        currentX += (targetX - currentX) * lerpFactor;
        currentY += (targetY - currentY) * lerpFactor;
        
        // Update scene camera
        scene.camera.x = currentX;
        scene.camera.y = currentY;
    }
    
    /**
     * Update camera using time-based damping
     */
    private function updateCameraDamping(targetX: Float, targetY: Float, dt: Float): Void {
        var dampingTime = config.smoothingValue;
        
        // Calculate damping factor
        var dampingFactor = 1.0 - Math.exp(-dt / dampingTime);
        
        // Apply damping to velocity
        velocityX += (targetX - currentX) * dampingFactor;
        velocityY += (targetY - currentY) * dampingFactor;
        
        // Update position
        currentX += velocityX * dt;
        currentY += velocityY * dt;
        
        // Update scene camera
        scene.camera.x = currentX;
        scene.camera.y = currentY;
    }
    
    /**
     * Get target position for entity with viewport offset
     */
    private function getTargetPosition(entity: BaseEntityModel): {x: Float, y: Float} {
        return {
            x: entity.renderPos.x + config.viewportOffsetX,
            y: entity.renderPos.y + config.viewportOffsetY
        };
    }
    
    /**
     * Set viewport offset
     */
    public function setViewportOffset(offsetX: Float, offsetY: Float): Void {
        config.viewportOffsetX = offsetX;
        config.viewportOffsetY = offsetY;
    }
    
    /**
     * Get camera configuration
     */
    public function getConfig(): CameraConfig {
        return config;
    }
    
    /**
     * Set new configuration
     */
    public function setConfig(newConfig: CameraConfig): Void {
        config = newConfig;
    }
    
    /**
     * Reset camera to origin
     */
    public function resetToOrigin(): Void {
        setCameraPosition(0, 0);
        velocityX = 0.0;
        velocityY = 0.0;
    }
    
    /**
     * Get camera state for debugging
     */
    public function getCameraState(): Dynamic {
        return {
            isFollowing: isFollowing,
            targetEntityId: targetEntityId,
            currentPosition: {x: currentX, y: currentY},
            smoothingMode: config.smoothingMode,
            smoothingValue: config.smoothingValue,
            enabled: config.enabled
        };
    }
}
