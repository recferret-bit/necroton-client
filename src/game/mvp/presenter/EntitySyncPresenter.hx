package game.mvp.presenter;

import engine.NecrotonEngine;
import engine.model.entities.EntityType;
import engine.model.entities.base.BaseEngineEntity;
import engine.presenter.InputMessage;
import engine.view.EventBusConstants;
import engine.view.EventBusTypes;
import engine.view.IEventBus;
import game.mvp.model.GameClientState;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.CharacterModel;
import game.mvp.model.entities.ColliderModel;
import game.mvp.model.entities.ConsumableModel;
import game.mvp.model.entities.EffectModel;

/**
 * Entity synchronization presenter
 * Subscribes to engine events and updates game client state
 * Handles entity lifecycle and state synchronization
 */
class EntitySyncPresenter {
    // Core components
    private var engine: NecrotonEngine;
    private var gameClientState: GameClientState;
    private var eventBus: IEventBus;
    
    // Event subscriptions
    private var eventTokens: Array<Int>;
    
    // Synchronization state
    private var isSubscribed: Bool;
    private var lastSyncTick: Int;
    
    // Server reconciliation state
    private var lastServerSnapshot: Dynamic;
    private var reconciliationThreshold: Float;
    private var isReconciling: Bool;
    
    public function new(engine: NecrotonEngine, gameClientState: GameClientState) {
        this.engine = engine;
        this.gameClientState = gameClientState;
        this.eventBus = engine.getEventBus();
        
        eventTokens = [];
        isSubscribed = false;
        lastSyncTick = 0;
        
        // Initialize reconciliation
        lastServerSnapshot = null;
        reconciliationThreshold = 0.1; // 0.1 unit position difference threshold
        isReconciling = false;
    }
    
    /**
     * Subscribe to engine events
     */
    public function subscribeToEvents(eventBus: IEventBus): Void {
        if (isSubscribed) return;
        
        this.eventBus = eventBus;
        
        // Subscribe to entity events with typed handlers
        var spawnToken = eventBus.subscribe(EventBusConstants.ENTITY_SPAWN, onEntitySpawn);
        var deathToken = eventBus.subscribe(EventBusConstants.ENTITY_DEATH, onEntityDeath);
        var moveToken = eventBus.subscribe(EventBusConstants.ENTITY_MOVE, onEntityMove);
        var correctionToken = eventBus.subscribe(EventBusConstants.ENTITY_CORRECTION, onEntityCorrection);
        var damageToken = eventBus.subscribe(EventBusConstants.ENTITY_DAMAGE, onEntityDamage);
        var collisionToken = eventBus.subscribe(EventBusConstants.ENTITY_COLLISION, onEntityCollision);
        var triggerToken = eventBus.subscribe(EventBusConstants.COLLIDER_TRIGGER, onColliderTrigger);
        
        // Store tokens for cleanup
        eventTokens.push(spawnToken);
        eventTokens.push(deathToken);
        eventTokens.push(moveToken);
        eventTokens.push(correctionToken);
        eventTokens.push(damageToken);
        eventTokens.push(collisionToken);
        eventTokens.push(triggerToken);
        
        isSubscribed = true;
        trace("EntitySyncPresenter subscribed to engine events");
    }
    
    /**
     * Unsubscribe from engine events
     */
    public function unsubscribeFromEvents(): Void {
        if (!isSubscribed) return;
        
        for (token in eventTokens) {
            eventBus.unsubscribe(token);
        }
        
        eventTokens = [];
        isSubscribed = false;
        trace("EntitySyncPresenter unsubscribed from engine events");
    }
    
    /**
     * Process pending events
     */
    public function processEvents(): Void {
        // Events are processed automatically through callbacks
        // This method can be used for batch processing if needed
    }
    
    /**
     * Handle server snapshot for reconciliation
     */
    public function handleServerSnapshot(snapshot: Dynamic): Void {
        if (isReconciling) return; // Prevent recursive reconciliation
        
        lastServerSnapshot = snapshot;
        
        // Check if we need to reconcile
        if (shouldReconcile(snapshot)) {
            performReconciliation(snapshot);
        }
    }
    
    /**
     * Check if reconciliation is needed
     */
    private function shouldReconcile(serverSnapshot: Dynamic): Bool {
        // Only reconcile in CLIENT_PREDICTION mode
        final engineConfig = GamePresenter.Config.engineConfig;
        if (engineConfig == null || engineConfig.mode != CLIENT_PREDICTION) {
            return false;
        }
        
        // Check if we have pending inputs to reconcile
        final pendingInputs = gameClientState.getPendingInputs();
        if (pendingInputs.length == 0) {
            return false;
        }
        
        // Check position differences for player character
        final playerEntity = gameClientState.getPlayerControlledEntity();
        if (playerEntity == null) {
            return false;
        }
        
        // Find corresponding entity in server snapshot
        final serverEntity = findEntityInSnapshot(serverSnapshot, playerEntity.engineEntity.id);
        if (serverEntity == null) {
            return false;
        }
        
        // Calculate position difference
        final posDiff = Math.sqrt(
            Math.pow(playerEntity.engineEntity.pos.x - serverEntity.pos.x, 2) +
            Math.pow(playerEntity.engineEntity.pos.y - serverEntity.pos.y, 2)
        );
        
        return posDiff > reconciliationThreshold;
    }
    
    /**
     * Perform reconciliation with server state
     */
    private function performReconciliation(serverSnapshot: Dynamic): Void {
        isReconciling = true;
        
        // Get pending inputs for rollback
        final pendingInputs = gameClientState.getPendingInputs();
        
        // Find the anchor tick (oldest pending input)
        final anchorTick = findAnchorTick(pendingInputs);
        if (anchorTick > 0) {
            // Perform rollback and replay
            engine.rollbackAndReplay(anchorTick, pendingInputs);
            
            // Clear acknowledged inputs
            final lastSequence = getLastSequenceFromInputs(pendingInputs);
            if (lastSequence > 0) {
                gameClientState.clearAcknowledgedInputs(lastSequence);
            }
        }
        
        // Update client state with server positions
        updateClientStateFromSnapshot(serverSnapshot);
        
        isReconciling = false;
    }
    
    /**
     * Find anchor tick from pending inputs
     */
    private function findAnchorTick(pendingInputs: Array<InputMessage>): Int {
        if (pendingInputs.length == 0) return 0;
        
        var minTick = pendingInputs[0].intendedServerTick;
        for (input in pendingInputs) {
            if (input.intendedServerTick < minTick) {
                minTick = input.intendedServerTick;
            }
        }
        return minTick;
    }
    
    /**
     * Get last sequence number from inputs
     */
    private function getLastSequenceFromInputs(pendingInputs: Array<InputMessage>): Int {
        if (pendingInputs.length == 0) return 0;
        
        var maxSequence = pendingInputs[0].sequence;
        for (input in pendingInputs) {
            if (input.sequence > maxSequence) {
                maxSequence = input.sequence;
            }
        }
        return maxSequence;
    }
    
    /**
     * Find entity in server snapshot
     */
    private function findEntityInSnapshot(snapshot: Dynamic, entityId: Int): Dynamic {
        if (snapshot.entities == null) return null;
        
        final entities: Array<Dynamic> = cast snapshot.entities;
        for (entity in entities) {
            if (entity.id == entityId) {
                return entity;
            }
        }
        return null;
    }
    
    /**
     * Update client state from server snapshot
     */
    private function updateClientStateFromSnapshot(serverSnapshot: Dynamic): Void {
        if (serverSnapshot.entities == null) return;
        
        final entities: Array<Dynamic> = cast serverSnapshot.entities;
        for (serverEntity in entities) {
            final clientModel = gameClientState.getEntity(serverEntity.id);
            if (clientModel != null && clientModel.engineEntity != null) {
                // Update position and velocity
                clientModel.engineEntity.pos.x = serverEntity.pos.x;
                clientModel.engineEntity.pos.y = serverEntity.pos.y;
                clientModel.engineEntity.vel.x = serverEntity.vel.x;
                clientModel.engineEntity.vel.y = serverEntity.vel.y;
                clientModel.needsVisualUpdate = true;
            }
        }
    }
    
    /**
     * Handle entity spawn event
     */
    private function onEntitySpawn(event: EntitySpawnEvent): Void {
        final entityId = event.entityId;
        final entityType = event.type;
        final pos = event.pos;
        final ownerId = event.ownerId;
        
        final engineEntity:BaseEngineEntity = switch (entityType) {
            case EntityType.CHARACTER:
                engine.getCharacterById(entityId);
            case EntityType.COLLIDER:
                engine.getColliderById(entityId);
            default:
                null;
        }

        if (engineEntity == null) {
            trace("Warning: Could not get engine entity for id: " + entityId);
            return;
        }

        // Create model based on type
        final model = createModelForTypeAndInitialize(entityType, engineEntity);
        if (model == null) {
            trace("Warning: Could not create model for entity type: " + entityType);
            return;
        }
        
        // Initialize model with event data
        if (model.engineEntity != null) {
            model.engineEntity.id = entityId;
            model.engineEntity.type = entityType;
            model.engineEntity.pos.x = pos.x;
            model.engineEntity.pos.y = pos.y;
            model.engineEntity.ownerId = ownerId;
            model.engineEntity.isAlive = true;
        }
        
        // Set visual properties
        model.setVisualProperties();
        
        // Add to game client state
        gameClientState.addEntity(model);
    }
    
    /**
     * Handle entity death event
     */
    private function onEntityDeath(event: EntityDeathEvent): Void {
        var entityId = event.entityId;
        var killerId = event.killerId;
        
        trace("Entity died: ID=" + entityId + ", Killer=" + killerId);
        
        // Mark entity as dead in game client state
        var model = gameClientState.getEntity(entityId);
        if (model != null && model.engineEntity != null) {
            model.engineEntity.isAlive = false;
            model.needsVisualUpdate = true;
        }
    }
    
    /**
     * Handle entity move event
     */
    private function onEntityMove(event: EntityMoveEvent): Void {
        var entityId = event.entityId;
        var pos = event.pos;
        var vel = event.vel;
        
        // Update model position
        var model = gameClientState.getEntity(entityId);
        if (model != null && model.engineEntity != null) {
            model.engineEntity.pos.x = pos.x;
            model.engineEntity.pos.y = pos.y;
            model.engineEntity.vel.x = vel.x;
            model.engineEntity.vel.y = vel.y;
            model.needsVisualUpdate = true;
        }
    }
    
    /**
     * Handle entity correction event
     */
    private function onEntityCorrection(event: EntityCorrectionEvent): Void {
        var entityId = event.entityId;
        var correctedPos = event.correctedPos;
        var correctedVel = event.correctedVel;
        
        trace("Entity correction: ID=" + entityId + ", Pos=" + correctedPos);
        
        // Update model with corrected values
        var model = gameClientState.getEntity(entityId);
        if (model != null && model.engineEntity != null) {
            model.engineEntity.pos.x = correctedPos.x;
            model.engineEntity.pos.y = correctedPos.y;
            model.engineEntity.vel.x = correctedVel.x;
            model.engineEntity.vel.y = correctedVel.y;
            model.needsVisualUpdate = true;
        }
    }
    
    /**
     * Handle entity damage event
     */
    private function onEntityDamage(event: EntityDamageEvent): Void {
        var entityId = event.entityId;
        var damage = event.damage;
        var attackerId = event.attackerId;
        
        trace("Entity damage: ID=" + entityId + ", Damage=" + damage + ", Attacker=" + attackerId);
        
        // Apply damage to character model
        var model = gameClientState.getEntity(entityId);
        if (model != null && Std.isOfType(model, CharacterModel)) {
            var characterModel = cast(model, CharacterModel);
            characterModel.takeDamage(damage);
        }
    }
    
    /**
     * Handle entity collision event
     */
    private function onEntityCollision(event: EntityCollisionEvent): Void {
        var entityIdA = event.entityIdA;
        var entityIdB = event.entityIdB;
        var contactPoint = event.contactPoint;
        var normal = event.normal;
        
        trace("Entity collision: " + entityIdA + " vs " + entityIdB + ", Contact=" + contactPoint);
        
        // Handle collision logic based on entity types
        handleCollision(Std.string(entityIdA), Std.string(entityIdB), "collision");
    }
    
    /**
     * Handle collision between entities
     */
    private function handleCollision(entityId1: String, entityId2: String, collisionType: String): Void {
        var model1 = gameClientState.getEntity(Std.parseInt(entityId1));
        var model2 = gameClientState.getEntity(Std.parseInt(entityId2));
        
        if (model1 == null || model2 == null) return;
        
        // Handle character vs consumable collision
        if (Std.isOfType(model1, CharacterModel) && Std.isOfType(model2, ConsumableModel)) {
            handleCharacterConsumableCollision(cast(model1, CharacterModel), cast(model2, ConsumableModel));
        } else if (Std.isOfType(model2, CharacterModel) && Std.isOfType(model1, ConsumableModel)) {
            handleCharacterConsumableCollision(cast(model2, CharacterModel), cast(model1, ConsumableModel));
        }
        
        // Handle character vs effect collision
        if (Std.isOfType(model1, CharacterModel) && Std.isOfType(model2, EffectModel)) {
            handleCharacterEffectCollision(cast(model1, CharacterModel), cast(model2, EffectModel));
        } else if (Std.isOfType(model2, CharacterModel) && Std.isOfType(model1, EffectModel)) {
            handleCharacterEffectCollision(cast(model2, CharacterModel), cast(model1, EffectModel));
        }
    }
    
    /**
     * Handle character consuming consumable
     */
    private function handleCharacterConsumableCollision(character: CharacterModel, consumable: ConsumableModel): Void {
        if (consumable.canConsume()) {
            // Apply consumable effect
            switch (consumable.consumableType) {
                case "health_potion":
                    character.heal(Std.int(consumable.effectValue));
                case "mana_potion":
                    // Handle mana restoration
                case "strength_potion":
                    // Handle strength boost
            }
            
            // Consume the item
            consumable.consume();
            
            trace("Character " + character.id + " consumed " + consumable.consumableType);
        }
    }
    
    /**
     * Handle character touching effect
     */
    private function handleCharacterEffectCollision(character: CharacterModel, effect: EffectModel): Void {
        if (!effect.isExpired()) {
            // Apply effect to character
            var effectValue = effect.applyEffect();
            
            switch (effect.effectType) {
                case "damage":
                    character.takeDamage(Std.int(effectValue));
                case "heal":
                    character.heal(Std.int(effectValue));
                case "speed_boost":
                    // Handle speed boost
                case "shield":
                    // Handle shield effect
            }
            
            trace("Character " + character.id + " affected by " + effect.effectType);
        }
    }
    
    /**
     * Handle collider trigger event
     */
    private function onColliderTrigger(event: ColliderTriggerEvent): Void {
        var entityId = event.entityId;
        var colliderId = event.colliderId;
        var triggerPos = event.triggerPos;
        
        trace("Collider trigger: Entity=" + entityId + ", Collider=" + colliderId + ", Pos=" + triggerPos);
        
        // Handle trigger logic here
        // For now, just trace the event
    }
    
    /**
     * Create model for entity type
     */
    private function createModelForTypeAndInitialize(entityType: EntityType, engineEntity: BaseEngineEntity): BaseEntityModel {
        var clientModel:BaseEntityModel = null;
        switch (entityType) {
            case CHARACTER:
                clientModel = new CharacterModel();
            case CONSUMABLE:
                clientModel = new ConsumableModel();
            case EFFECT:
                clientModel = new EffectModel();
            case COLLIDER:
                clientModel = new ColliderModel();
            default:
        }
        if (clientModel == null) {
            trace("Warning: Could not create model for entity type: " + entityType);
            return null;
        }
        clientModel.initialize(engineEntity);
        return clientModel;
    }
    /**
     * Get synchronization statistics
     */
    public function getSyncStats(): Dynamic {
        return {
            isSubscribed: isSubscribed,
            eventTokenCount: eventTokens.length,
            lastSyncTick: lastSyncTick,
            gameClientStateCount: gameClientState.getTotalEntityCount()
        };
    }
    
    /**
     * Destroy entity sync presenter
     */
    public function destroy(): Void {
        unsubscribeFromEvents();
        engine = null;
        gameClientState = null;
        eventBus = null;
    }
}
