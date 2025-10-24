package game.mvp.view.entities;

import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.ColliderModel;
import game.mvp.presenter.GamePresenter;
import h2d.Object;

/**
 * Collider entity view extending BaseGameEntityView
 * Simple red rectangle visualization for colliders
 */
class ColliderEntityView extends BaseGameEntityView {
    
    public function new(parent: Object = null) {
        super(parent);
    }
    
    /**
     * Initialize collider view
     */
    override public function initialize(model: BaseEntityModel): Void {
        super.initialize(model);
    }
    
    
    /**
     * Update collider view
     */
    override public function update(): Void {
        if (!isInitialized || model == null || !model.isAlive) {
            return;
        }
        
        // Colliders are static, no interpolation needed
        // Just update position directly
        updatePosition();
    }
    
    /**
     * Update position from model (no interpolation for static colliders)
     */
    override private function updatePosition(): Void {
        if (model != null) {
            // Use direct position for static colliders
            x = model.pos.x;
            y = model.pos.y;
        }
    }
    
    
    /**
     * Get collider model
     */
    public function getColliderModel(): ColliderModel {
        return cast(model, ColliderModel);
    }
    
    /**
     * Reset for object pooling
     */
    override public function reset(): Void {
        // Call parent reset
        super.reset();
    }
    
    /**
     * Destroy collider view
     */
    override public function destroy(): Void {
        super.destroy();
    }
}
