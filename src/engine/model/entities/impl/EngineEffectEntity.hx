package engine.model.entities.impl;

import engine.model.EntityType;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Effect entity (buffs, debuffs, visual effects)
 */
class EngineEffectEntity extends BaseEngineEntity {
    public var effectType: String;
    public var durationTicks: Int;
    public var intensity: Float;
    public var targetId: Int;
    public var casterId: Int;
    
    public function new() {
        super();
    }
    
    // TODO replace by typings
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.effectType = effectType;
        base.durationTicks = durationTicks;
        base.intensity = intensity;
        base.targetId = targetId;
        base.casterId = casterId;
        return base;
    }
    
    // TODO replace by typings
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);

        effectType = data.effectType;
        durationTicks = data.durationTicks;
        intensity = data.intensity;
        targetId = data.targetId;
        casterId = data.casterId;
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);

        effectType = spec.effectType != null ? spec.effectType : "";
        durationTicks = spec.durationTicks != null ? spec.durationTicks : 0;
        intensity = spec.intensity != null ? spec.intensity : 1.0;
        targetId = spec.targetId != null ? spec.targetId : 0;
        casterId = spec.casterId != null ? spec.casterId : 0;
    }
}
