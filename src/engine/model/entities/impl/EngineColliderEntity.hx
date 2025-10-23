package engine.model.entities.impl;

import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Collider entity for map building and collision detection
 * Static entities that can be passable or impassable, with optional trigger functionality
 */
class EngineColliderEntity extends BaseEngineEntity {
    public var passable: Bool;
    public var isTrigger: Bool;
    
    public function new() {
        super();
    }
    
    // TODO replace by typings
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.passable = passable;
        base.isTrigger = isTrigger;
        return base;
    }
    
    // TODO replace by typings
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);
        passable = data.passable != null ? data.passable : false;
        isTrigger = data.isTrigger != null ? data.isTrigger : false;
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);

        if (spec == null) {
            passable = false;
            isTrigger = false;
            isInputDriven = false;
            vel.x = 0;
            vel.y = 0;
            colliderWidth = 1;
            colliderHeight = 1;
            return;
        }

        passable = spec.passable != null ? spec.passable : false;
        isTrigger = spec.isTrigger != null ? spec.isTrigger : false;
        
        // Colliders are always static
        isInputDriven = false;
        vel.x = 0;
        vel.y = 0;

        colliderWidth = spec.colliderWidth != null ? spec.colliderWidth : 1;
        colliderHeight = spec.colliderHeight != null ? spec.colliderHeight : 1;
    }
}
