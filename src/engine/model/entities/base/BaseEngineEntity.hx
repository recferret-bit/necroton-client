package engine.model.entities.base;

import engine.geometry.Vec2;
import engine.geometry.Vec2Utils;
import engine.model.EntityType;
import engine.model.entities.base.AbstractEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Abstract base entity with common fields and default implementations
 */
abstract class BaseEngineEntity extends AbstractEngineEntity {
    
    /** Movement correction */
    var movementCorrection: Vec2 = Vec2Utils.create(0, 0);

    public function new() {
        reset(null);
    }
    
    /**
     * Abstarct interface implementation
     */

    public function serialize(): Dynamic {
        return {
            id: id,
            type: type,
            pos: {x: pos.x, y: pos.y},
            vel: {x: vel.x, y: vel.y},
            rotation: rotation,
            ownerId: ownerId,
            isAlive: isAlive,
            isInputDriven: isInputDriven,
            colliderWidth: colliderWidth,
            colliderHeight: colliderHeight
        };
    }
    
    public function deserialize(data: Dynamic): Void {
        id = data.id;
        type = data.type;
        pos = {x: data.pos.x, y: data.pos.y};
        vel = {x: data.vel.x, y: data.vel.y};
        rotation = data.rotation;
        ownerId = data.ownerId;
        isAlive = data.isAlive;
        isInputDriven = data.isInputDriven != null ? data.isInputDriven : false;
        colliderWidth = data.colliderWidth != null ? data.colliderWidth : 1;
        colliderHeight = data.colliderHeight != null ? data.colliderHeight : 1;
    }
    
    public function reset(spec: EngineEntitySpec): Void {
        if (spec == null) {
            id = 0;
            type = EntityType.GENERIC;
            pos = Vec2Utils.create(0, 0);
            vel = Vec2Utils.create(0, 0);
            rotation = 0;
            ownerId = "";
            isAlive = false;
            isInputDriven = false;
            colliderWidth = 1;
            colliderHeight = 1;
            return;
        }

        id = spec.id != null ? spec.id : 0;
        type = spec.type != null ? spec.type : EntityType.GENERIC;
        pos = spec.pos != null ? {x: spec.pos.x, y: spec.pos.y} : Vec2Utils.create(0, 0);
        vel = spec.vel != null ? {x: spec.vel.x, y: spec.vel.y} : Vec2Utils.create(0, 0);
        rotation = spec.rotation != null ? spec.rotation : 0;
        ownerId = spec.ownerId != null ? spec.ownerId : "";
        isAlive = spec.isAlive != null ? spec.isAlive : true;
        isInputDriven = spec.isInputDriven != null ? spec.isInputDriven : false;
        colliderWidth = spec.colliderWidth != null ? spec.colliderWidth : 1;
        colliderHeight = spec.colliderHeight != null ? spec.colliderHeight : 1;
    }

    /**
     * Apply movement correction
     */
    public function applyMovementCorrection(correction: Vec2): Void {
        movementCorrection = correction;
    }

    /**
     * Reset movement correction
     */
    public function clearMovementCorrection(): Void {
        movementCorrection = Vec2Utils.create(0, 0);
    }
}
