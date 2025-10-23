package engine.modules;

import engine.EngineConfig;
import engine.model.EntityType;
import engine.model.GameModelState;
import engine.model.entities.impl.EngineCharacterEntity;
import engine.model.managers.IEngineEntityManager;
import engine.presenter.InputBuffer;
import engine.presenter.InputMessage;

/**
 * Input module for handling player inputs
 */
class InputModule implements IModule {
    private final inputBuffers: Map<String, InputBuffer> = new Map();
    private final clientEntityMap: Map<String, Int> = new Map();
    
    public function new() {
    }
    
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Collect inputs for this tick
        final inputs = collectForTick(tick);
        
        // Apply inputs to state
        if (inputs.length > 0) {
            applyInputs(inputs, state, dt);
        }
    }
    
    public function shutdown(): Void {
        inputBuffers.clear();
    }
    
    /**
     * Queue input from client
     * @param input Input message
     */
    public function queueInput(input: InputMessage): Void {
        if (!inputBuffers.exists(input.clientId)) {
            inputBuffers.set(input.clientId, new InputBuffer());
        }
        
        inputBuffers.get(input.clientId).push(input);
    }
    
    /**
     * Set client to entity mapping
     * @param clientId Client ID
     * @param entityId Entity ID
     */
    public function setClientEntity(clientId: String, entityId: Int): Void {
        clientEntityMap.set(clientId, entityId);
    }
    
    /**
     * Collect inputs for specific tick
     * @param tick Target tick
     * @return Array of inputs for this tick
     */
    public function collectForTick(tick: Int): Array<InputMessage> {
        var result = [];
        
        for (clientId in inputBuffers.keys()) {
            final buffer = inputBuffers.get(clientId);
            final inputs = buffer.collectForTick(tick);
            result = result.concat(inputs);
        }
        
        return result;
    }
    
    /**
     * Apply inputs to game state
     * @param inputs Input messages
     * @param state Game state
     * @param dt Delta time
     */
    public function applyInputs(inputs: Array<InputMessage>, state: GameModelState, dt: Float): Void {
        final characterManager: IEngineEntityManager<EngineCharacterEntity> = state.managers.get(EntityType.CHARACTER);
        
        for (input in inputs) {
            // Get entity ID from client mapping
            final entityId = clientEntityMap.get(input.clientId);
            if (entityId != null && characterManager != null) {
                final character = characterManager.find(entityId);
                if (character != null) {
                    // Apply step-based movement directly to position
                    character.applyMovementStep(input.movement.x, input.movement.y, dt);
                    
                    // Process actions if any
                    for (action in input.actions) {
                        // Handle different action types
                        switch (action.type) {
                            case "primary_action":
                                // Handle primary action (e.g., attack)
                                trace('Primary action from ${input.clientId}');
                            case "secondary_action":
                                // Handle secondary action (e.g., block)
                                trace('Secondary action from ${input.clientId}');
                            case "ability":
                                // Handle ability usage
                                trace('Ability from ${input.clientId}');
                            default:
                                // Handle other actions
                                trace('Unknown action: ${action.type} from ${input.clientId}');
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Drop acknowledged inputs
     * @param clientId Client ID
     * @param sequence Last acknowledged sequence
     */
    public function dropAcknowledged(clientId: String, sequence: Int): Void {
        if (inputBuffers.exists(clientId)) {
            inputBuffers.get(clientId).dropUpToSequence(sequence);
        }
    }
}
