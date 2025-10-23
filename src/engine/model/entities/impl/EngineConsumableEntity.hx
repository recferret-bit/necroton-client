package engine.model.entities.impl;

import engine.model.EntityType;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Consumable item entity (potions, food, etc.)
 */
class EngineConsumableEntity extends BaseEngineEntity {
    public var effectId: String;
    public var durationTicks: Int;
    public var stackable: Bool;
    public var charges: Int;
    public var useRange: Float;
    
    public function new() {
        super();
    }
    
    // TODO replace by typings
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.effectId = effectId;
        base.durationTicks = durationTicks;
        base.stackable = stackable;
        base.charges = charges;
        base.useRange = useRange;
        return base;
    }
    
    // TODO replace by typings
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);
        effectId = data.effectId;
        durationTicks = data.durationTicks;
        stackable = data.stackable;
        charges = data.charges;
        useRange = data.useRange;
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);
        effectId = spec.effectId != null ? spec.effectId : "";
        durationTicks = spec.durationTicks != null ? spec.durationTicks : 0;
        stackable = spec.stackable != null ? spec.stackable : false;
        charges = spec.charges != null ? spec.charges : 1;
        useRange = spec.useRange != null ? spec.useRange : 16;
    }
}
