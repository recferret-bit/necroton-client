package game.mvp.presenter;

import engine.NecrotonEngine;
import engine.presenter.InputMessage;
import game.mvp.model.GameClientState;
import hxd.Key;

/**
 * Input presenter for handling player input
 * Captures Heaps input and converts to engine InputMessage format
 * Manages input state and queuing to engine
 */
class InputPresenter {
    // Core components
    private var engine: NecrotonEngine;
    private var gameClientState: GameClientState;
    
    // Input stateS
    private var clientId: String;
    private var controlledEntityId: Null<Int>;
    private var sequenceNumber: Int;
    private var lastInputTime: Float;
    
    // Input buffering
    private var inputBuffer: Array<InputMessage>;
    private var maxBufferSize: Int;
    
    // Input configuration
    private var inputSensitivity: Float;
    private var inputDeadzone: Float;
    
    // Input sampling and state tracking
    private var lastMovement: {x: Float, y: Float};
    private var inputFrameCounter: Int;
    private var inputSamplingRate: Int;
    private var estimatedLatency: Int; // For CLIENT_PREDICTION mode
    
    // Client prediction state
    private var predictionHistory: Array<Dynamic>;
    private var maxPredictionHistory: Int;
    
    public function new(engine: NecrotonEngine, gameClientState: GameClientState) {
        this.engine = engine;
        this.gameClientState = gameClientState;
        
        // Initialize input state
        clientId = "player1";
        sequenceNumber = 0;
        lastInputTime = 0;
        
        // Initialize input buffering
        inputBuffer = [];
        maxBufferSize = 10;
        
        // Initialize input configuration
        inputSensitivity = 1.0;
        inputDeadzone = 0.1;
        
        // Initialize input sampling
        lastMovement = {x: 0.0, y: 0.0};
        inputFrameCounter = 0;
        inputSamplingRate = 1; // Send every frame for maximum responsiveness
        estimatedLatency = 2; // 2 tick latency estimate for CLIENT_PREDICTION mode
        
        // Initialize client prediction
        predictionHistory = [];
        maxPredictionHistory = 50;
    }
    
    /**
     * Update input presenter
     */
    public function update(dt: Float, engineTick: Int): Void {
        inputFrameCounter++;
        
        // Capture current input state
        final inputState = captureInputState();
        
        // Check if we should send input (changed state or sampling interval reached)
        if (shouldSendInput(inputState)) {
            final inputMessage = createInputMessage(inputState, engineTick);
            queueInput(inputMessage);
            
            // Apply client-side prediction for immediate response
            applyLocalPrediction(inputMessage);
        }
        
        // Update last movement state
        lastMovement = {x: inputState.movement.x, y: inputState.movement.y};
        
        // Process input buffer
        processInputBuffer();
    }
    
    /**
     * Capture current input state
     */
    private function captureInputState(): InputState {
        final inputState = new InputState();
        
        // Capture movement input
        inputState.movement = captureMovementInput();
        
        // Capture action input
        inputState.actions = captureActionInput();
        
        // Capture other input
        inputState.other = captureOtherInput();
        
        return inputState;
    }
    
    /**
     * Capture movement input (WASD/Arrow keys)
     */
    private function captureMovementInput(): {x: Float, y: Float} {
        var movement = {x: 0.0, y: 0.0};
        
        // Horizontal movement
        if (Key.isDown(Key.A) || Key.isDown(Key.LEFT)) {
            movement.x -= 1.0;
        }
        if (Key.isDown(Key.D) || Key.isDown(Key.RIGHT)) {
            movement.x += 1.0;
        }
        
        // Vertical movement
        if (Key.isDown(Key.W) || Key.isDown(Key.UP)) {
            movement.y -= 1.0;
        }
        if (Key.isDown(Key.S) || Key.isDown(Key.DOWN)) {
            movement.y += 1.0;
        }
        
        // Apply deadzone
        if (Math.abs(movement.x) < inputDeadzone) {
            movement.x = 0.0;
        }
        if (Math.abs(movement.y) < inputDeadzone) {
            movement.y = 0.0;
        }
        
        // Apply sensitivity
        movement.x *= inputSensitivity;
        movement.y *= inputSensitivity;
        
        return movement;
    }
    
    /**
     * Capture action input (Space, etc.)
     */
    private function captureActionInput(): Array<Dynamic> {
        var actions = [];
        
        // Space key for primary action
        if (Key.isPressed(Key.SPACE)) {
            actions.push({
                type: "primary_action",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        // Shift key for secondary action
        if (Key.isPressed(Key.SHIFT)) {
            actions.push({
                type: "secondary_action",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        // Number keys for abilities
        if (Key.isPressed(Key.NUMBER_1)) {
            actions.push({
                type: "ability",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        if (Key.isPressed(Key.NUMBER_2)) {
            actions.push({
                type: "ability",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        if (Key.isPressed(Key.NUMBER_3)) {
            actions.push({
                type: "ability",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        return actions;
    }
    
    /**
     * Capture other input (Escape, etc.)
     */
    private function captureOtherInput(): Array<Dynamic> {
        var other = [];
        
        // Escape key for menu
        if (Key.isPressed(Key.ESCAPE)) {
            other.push({
                type: "menu",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        // Tab key for inventory
        if (Key.isPressed(Key.TAB)) {
            other.push({
                type: "inventory",
                timestamp: hxd.Timer.lastTimeStamp
            });
        }
        
        return other;
    }
    
    /**
     * Check if there's any input
     */
    private function hasInput(inputState: InputState): Bool {
        var hasMovement = Math.abs(inputState.movement.x) > 0 || Math.abs(inputState.movement.y) > 0;
        var hasActions = inputState.actions.length > 0;
        var hasOther = inputState.other.length > 0;
        
        return hasMovement || hasActions || hasOther;
    }
    
    /**
     * Check if we should send input (prevent duplicates)
     */
    private function shouldSendInput(inputState: InputState): Bool {
        if (!hasInput(inputState)) return false;
        
        // Always send actions (they're discrete events)
        if (inputState.actions.length > 0 || inputState.other.length > 0) {
            return true;
        }
        
        // For movement: check if direction changed or sampling interval reached
        var movementChanged = (inputState.movement.x != lastMovement.x || 
                              inputState.movement.y != lastMovement.y);
        var intervalReached = (inputFrameCounter % inputSamplingRate == 0);
        
        return movementChanged || intervalReached;
    }
    
    /**
     * Create input message from input state
     */
    private function createInputMessage(inputState: InputState, engineTick: Int): InputMessage {
        final currentTime = hxd.Timer.lastTimeStamp;
        
        // Calculate latency offset based on engine mode
        var latencyOffset = 0;
        final engineConfig = GamePresenter.Config.engineConfig;
        if (engineConfig != null && engineConfig.mode == CLIENT_PREDICTION) {
            latencyOffset = estimatedLatency;
        }
        
        final intendedTick = engineTick + 1 + latencyOffset;
        
        return {
            clientId: clientId,
            sequence: sequenceNumber++,
            clientTick: engineTick,
            intendedServerTick: intendedTick,
            movement: inputState.movement,
            actions: inputState.actions.concat(inputState.other),
            timestamp: currentTime
        };
    }
    
    /**
     * Queue input to engine
     */
    private function queueInput(inputMessage: InputMessage): Void {
        // Add to buffer
        inputBuffer.push(inputMessage);
        
        // Limit buffer size
        if (inputBuffer.length > maxBufferSize) {
            inputBuffer.shift();
        }
        
        // Track pending input for prediction
        gameClientState.addPendingInput(inputMessage);
        
        // Queue to engine
        engine.queueInput(inputMessage);
        
        lastInputTime = hxd.Timer.lastTimeStamp;
    }
    
    /**
     * Process input buffer
     */
    private function processInputBuffer(): Void {
        // Remove old inputs (older than 1 second)
        var currentTime = hxd.Timer.lastTimeStamp;
        inputBuffer = inputBuffer.filter(function(input) {
            return (currentTime - input.clientTick / 60.0) < 1.0;
        });
    }
    
    /**
     * Get input buffer
     */
    public function getInputBuffer(): Array<InputMessage> {
        return inputBuffer.copy();
    }
    
    /**
     * Clear input buffer
     */
    public function clearInputBuffer(): Void {
        inputBuffer = [];
    }
    
    /**
     * Set client ID
     */
    public function setClientId(clientId: String): Void {
        this.clientId = clientId;
    }
    
    /**
     * Get client ID
     */
    public function getClientId(): String {
        return clientId;
    }
    
    /**
     * Set controlled entity
     */
    public function setControlledEntity(entityId: Int, clientId: String): Void {
        this.controlledEntityId = entityId;
        this.clientId = clientId;
    }
    
    /**
     * Get controlled entity ID
     */
    public function getControlledEntityId(): Null<Int> {
        return controlledEntityId;
    }
    
    /**
     * Set input sensitivity
     */
    public function setInputSensitivity(sensitivity: Float): Void {
        this.inputSensitivity = sensitivity;
    }
    
    /**
     * Set input deadzone
     */
    public function setInputDeadzone(deadzone: Float): Void {
        this.inputDeadzone = deadzone;
    }
    
    /**
     * Apply client-side prediction for immediate response
     */
    private function applyLocalPrediction(inputMessage: InputMessage): Void {
        // Only apply prediction in CLIENT_PREDICTION mode
        final engineConfig = GamePresenter.Config.engineConfig;
        if (engineConfig == null || engineConfig.mode != CLIENT_PREDICTION) {
            return;
        }
        
        // Get controlled character from engine
        if (controlledEntityId != null) {
            final character = engine.getCharacterById(controlledEntityId);
            if (character != null) {
                // Apply step-based movement prediction immediately
                var dt = 1.0 / 60.0; // Assume 60 FPS for prediction

                // Apply step-based movement prediction immediately
                character.applyMovementStep(inputMessage.movement.x, inputMessage.movement.y, dt);
                
                // Store prediction for later reconciliation
                predictionHistory.push({
                    sequence: inputMessage.sequence,
                    input: inputMessage,
                    predictedPos: {x: character.pos.x, y: character.pos.y},
                    predictedVel: {x: character.vel.x, y: character.vel.y}
                });
                
                // Limit prediction history size
                if (predictionHistory.length > maxPredictionHistory) {
                    predictionHistory.shift();
                }
            }
        }
    }
    
    /**
     * Handle server acknowledgment for CLIENT_PREDICTION mode
     */
    public function handleServerAcknowledgment(acknowledgedSequence: Int): Void {
        // Clear acknowledged inputs from game client state
        gameClientState.clearAcknowledgedInputs(acknowledgedSequence);
        
        // Remove acknowledged predictions from history
        predictionHistory = predictionHistory.filter(function(prediction) {
            return prediction.sequence > acknowledgedSequence;
        });
    }
    
    /**
     * Get input statistics
     */
    public function getInputStats(): Dynamic {
        return {
            clientId: clientId,
            sequenceNumber: sequenceNumber,
            bufferSize: inputBuffer.length,
            lastInputTime: lastInputTime,
            sensitivity: inputSensitivity,
            deadzone: inputDeadzone,
            predictionHistorySize: predictionHistory.length,
            pendingInputs: gameClientState.getPendingInputs().length
        };
    }
    
    /**
     * Destroy input presenter
     */
    public function destroy(): Void {
        inputBuffer = [];
        engine = null;
    }
}

/**
 * Input state container
 */
class InputState {
    public var movement: {x: Float, y: Float};
    public var actions: Array<Dynamic>;
    public var other: Array<Dynamic>;
    
    public function new() {
        movement = {x: 0.0, y: 0.0};
        actions = [];
        other = [];
    }
}
