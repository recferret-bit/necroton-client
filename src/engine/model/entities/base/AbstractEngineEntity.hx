package engine.model.entities.base;

import engine.geometry.Vec2;
import engine.model.EntityType;
import engine.model.entities.base.EngineEntitySpec;

/**
 * Entity contract for all game entities
 */
abstract class AbstractEngineEntity {
    /** Unique entity identifier */
    public var id: Int;
    
    /** Entity type */
    public var type: EntityType;
    
    /** World position */
    public var pos: Vec2;
    
    /** Velocity */
    public var vel: Vec2;
    
    /** Rotation in radians */
    public var rotation: Float;
    
    /** Owner/client ID */
    public var ownerId: String;
    
    /** Whether entity is alive */
    public var isAlive: Bool;
    
    /** Whether entity is input-driven (movement controlled by player input) */
    public var isInputDriven: Bool;

    /** Collider width */
    public var colliderWidth: Float;

    /** Collider height */
    public var colliderHeight: Float;
    
    /**
     * Serialize entity to JSON-serializable object
     * @return Serialized data
     */
    public abstract function serialize(): Dynamic;
    
    /**
     * Deserialize entity from data
     * @param data Serialized data
     */
    public abstract function deserialize(data: Dynamic): Void;
    
    /**
     * Reset entity to initial state from spec
     * @param spec Entity specification
     */
    public abstract function reset(spec: EngineEntitySpec): Void;
}
