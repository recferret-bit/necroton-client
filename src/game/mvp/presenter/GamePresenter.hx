package game.mvp.presenter;

import engine.NecrotonEngine;
import engine.model.entities.EngineEntitySpecs;
import engine.model.entities.base.EngineEntitySpec;
import game.config.GameClientConfig;
import game.mvp.model.GameClientState;
import game.mvp.presenter.EntitySyncPresenter;
import game.mvp.presenter.InputPresenter;
import game.mvp.view.GameViewOrchestrator;

/**
 * Main game presenter coordinating MVP components
 * Owns NecrotonEngine instance and coordinates other presenters
 * Main update loop and engine synchronization
 */
class GamePresenter {
    public static final Config: GameClientConfig = GameClientConfig.createSingleplayer();

    // Core components
    private var engine: NecrotonEngine;
    private var gameClientState: GameClientState;
    private var viewOrchestrator: GameViewOrchestrator;
    
    // Sub-presenters
    private var inputPresenter: InputPresenter;
    private var entitySyncPresenter: EntitySyncPresenter;
    
    // Configuration
    private var isRunning: Bool;
    private var currentTick: Int;
    
    // Performance tracking
    private var lastUpdateTime: Float;
    private var frameCount: Int;
    private var fps: Float;
    
    public function new(parent: h2d.Object) {
        isRunning = false;
        currentTick = 0;
        lastUpdateTime = 0;
        frameCount = 0;
        fps = 0;
        
        // Initialize components
        initializeComponents(parent);
    }
    
    /**
     * Initialize all MVP components
     */
    private function initializeComponents(parent: h2d.Object): Void {
        // Create game client state
        gameClientState = new GameClientState();
        
        // Create view orchestrator with scene reference
        viewOrchestrator = new GameViewOrchestrator(gameClientState, parent, cast(parent, h2d.Scene));
        
        // Create engine with config
        engine = NecrotonEngine.create(Config.engineConfig);
        
        // Create sub-presenters
        inputPresenter = new InputPresenter(engine, gameClientState);
        entitySyncPresenter = new EntitySyncPresenter(engine, gameClientState);
        
        // Setup event subscriptions
        setupEventSubscriptions();
    }
    
    /**
     * Setup event subscriptions for synchronization
     */
    private function setupEventSubscriptions(): Void {
        // Subscribe to engine events
        var eventBus = engine.getEventBus();
        
        // Entity spawn events
        entitySyncPresenter.subscribeToEvents(eventBus);
    }
    
    /**
     * Start the game
     */
    public function start(): Void {
        if (isRunning) return;
        
        isRunning = true;
        engine.start();
        
        // Spawn initial entities
        spawnInitialEntities();
        
        trace("GamePresenter started");
    }
    
    /**
     * Stop the game
     */
    public function stop(): Void {
        if (!isRunning) return;
        
        isRunning = false;
        engine.stop();
        
        trace("GamePresenter stopped");
    }
    
    /**
     * Main update loop
     */
    public function update(dt: Float): Void {
        if (!isRunning) return;
        
        // Update performance tracking
        updatePerformanceTracking(dt);
        
        // 1. Process input
        inputPresenter.update(dt, engine.getCurrentTick());
        
        // 2. Step engine simulation
        engine.step(dt);
        
        // 3. Process entity synchronization
        entitySyncPresenter.processEvents();
        
        // 4. Update game client state
        gameClientState.update(dt, currentTick);
        
        // 5. Sync views with models
        viewOrchestrator.syncWithModels();
        
        // 6. Update view orchestrator
        viewOrchestrator.update(dt);
        
        // 7. Clean up dead entities
        gameClientState.cleanupDeadEntities();
        
        currentTick++;
    }
    
    /**
     * Update performance tracking
     */
    private function updatePerformanceTracking(dt: Float): Void {
        frameCount++;
        lastUpdateTime += dt;
        
        if (lastUpdateTime >= 1.0) {
            fps = frameCount / lastUpdateTime;
            frameCount = 0;
            lastUpdateTime = 0;
        }
    }
    
    /**
     * Spawn initial entities
     */
    private function spawnInitialEntities(): Void {
        // Spawn player character
        var playerSpec = EngineEntitySpecs.getPlayerCharacterSpec();
        var playerId = engine.spawnEntity(playerSpec);
        
        // Set up player controlled entity tracking
        gameClientState.setPlayerControlledEntity(playerId);
        inputPresenter.setControlledEntity(playerId, "player1");
        
        // Set up InputModule client-entity mapping
        var inputModule = engine.getInputModule();
        if (inputModule != null) {
            inputModule.setClientEntity("player1", playerId);
        }
        
        // Set up camera to follow player
        var cameraController = viewOrchestrator.getCameraController();
        if (cameraController != null) {
            cameraController.followEntity(playerId);
        }
        
        // Spawn AI acolytes
        // var acolytePositions = EntitySpecs.getSpawnPositions().acolytes;
        // for (i in 0...acolytePositions.length) {
        //     var acolyteSpec = EntitySpecs.getIdleAcolyteSpec();
        //     acolyteSpec.pos = acolytePositions[i];
        //     var acolyteId = engine.spawnEntity(CHARACTER, acolyteSpec);
        //     trace("Spawned acolyte with ID: " + acolyteId);
        // }
        
        // // Spawn monsters
        // var monsterPositions = EntitySpecs.getSpawnPositions().monsters;
        // for (i in 0...monsterPositions.length) {
        //     var monsterSpec = EntitySpecs.getMonsterSpec();
        //     monsterSpec.pos = monsterPositions[i];
        //     var monsterId = engine.spawnEntity(CHARACTER, monsterSpec);
        //     trace("Spawned monster with ID: " + monsterId);
        // }
        
        // // Spawn consumables
        // var consumablePositions = EntitySpecs.getSpawnPositions().consumables;
        // for (i in 0...consumablePositions.length) {
        //     var consumableSpec = EntitySpecs.getEntitySpec(CONSUMABLE, i);
        //     consumableSpec.pos = consumablePositions[i];
        //     var consumableId = engine.spawnEntity(CONSUMABLE, consumableSpec);
        //     trace("Spawned consumable with ID: " + consumableId);
        // }
        
        // Spawn map colliders in chess pattern
        spawnMapColliders();
        
        // // Spawn effects
        // var effectPositions = EntitySpecs.getSpawnPositions().effects;
        // for (i in 0...effectPositions.length) {
        //     var effectSpec = EntitySpecs.getEntitySpec(EFFECT, i);
        //     effectSpec.pos = effectPositions[i];
        //     var effectId = engine.spawnEntity(EFFECT, effectSpec);
        //     trace("Spawned effect with ID: " + effectId);
        // }
    }
    
    /**
     * Spawn entity by type and spec
     */
    public function spawnEntity(spec: EngineEntitySpec): Int {
        return engine.spawnEntity(spec);
    }
    
    /**
     * Despawn entity by ID
     */
    public function despawnEntity(entityId: Int): Void {
        engine.despawnEntity(entityId);
    }
    
    /**
     * Get game client state
     */
    public function getGameClientState(): GameClientState {
        return gameClientState;
    }
    
    /**
     * Get view orchestrator
     */
    public function getViewOrchestrator(): GameViewOrchestrator {
        return viewOrchestrator;
    }
    
    /**
     * Get engine instance
     */
    public function getEngine(): NecrotonEngine {
        return engine;
    }
    
    /**
     * Get input presenter
     */
    public function getInputPresenter(): InputPresenter {
        return inputPresenter;
    }
    
    /**
     * Get entity sync presenter
     */
    public function getEntitySyncPresenter(): EntitySyncPresenter {
        return entitySyncPresenter;
    }
    
    /**
     * Get camera controller
     */
    public function getCameraController(): game.mvp.view.camera.CameraController {
        return viewOrchestrator.getCameraController();
    }
    
    /**
     * Update camera centering for screen size changes
     */
    public function updateCameraCentering(): Void {
        viewOrchestrator.updateCameraCentering();
    }
    
    /**
     * Check if game is running
     */
    public function isGameRunning(): Bool {
        return isRunning;
    }
    
    /**
     * Get current tick
     */
    public function getCurrentTick(): Int {
        return currentTick;
    }
    
    /**
     * Get FPS
     */
    public function getFPS(): Float {
        return fps;
    }
    
    /**
     * Get game state summary
     */
    public function getGameStateSummary(): Dynamic {
        return {
            isRunning: isRunning,
            currentTick: currentTick,
            fps: fps,
            gameClientState: gameClientState.getStateSummary(),
            viewOrchestrator: viewOrchestrator.getOrchestratorSummary(),
            // engineState: engine.getGameState()
        };
    }
    
    /**
     * Set debug info visibility
     */
    public function setDebugInfoVisible(visible: Bool): Void {
        viewOrchestrator.setDebugInfoVisible(visible);
    }
    
    /**
     * Set object pooling enabled
     */
    public function setObjectPoolingEnabled(enabled: Bool): Void {
        viewOrchestrator.setObjectPoolingEnabled(enabled);
    }
    
    /**
     * Handle server snapshot for reconciliation (CLIENT_PREDICTION mode)
     */
    public function handleServerSnapshot(snapshot: Dynamic): Void {
        entitySyncPresenter.handleServerSnapshot(snapshot);
    }
    
    /**
     * Handle server acknowledgment (CLIENT_PREDICTION mode)
     */
    public function handleServerAcknowledgment(acknowledgedSequence: Int): Void {
        inputPresenter.handleServerAcknowledgment(acknowledgedSequence);
    }
    
    /**
     * Destroy presenter
     */
    public function destroy(): Void {
        stop();
        
        if (viewOrchestrator != null) {
            viewOrchestrator.destroy();
        }
        
        if (entitySyncPresenter != null) {
            entitySyncPresenter.destroy();
        }
        
        if (inputPresenter != null) {
            inputPresenter.destroy();
        }
        
        engine = null;
        gameClientState = null;
    }
    
    /**
     * Spawn map colliders in chess pattern
     */
    private function spawnMapColliders(): Void {
        // Generate 10x10 grid of colliders with 10 unit spacing
        final colliderSpecs = EngineEntitySpecs.generateMapColliders(1, 1);
        
        for (spec in colliderSpecs) {
            engine.spawnEntity(spec);
        }
        
        trace("Spawned " + colliderSpecs.length + " map colliders in chess pattern");
    }
}
