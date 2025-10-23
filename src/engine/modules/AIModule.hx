package engine.modules;

import engine.model.EntityType;
import engine.model.GameModelState;
import engine.model.entities.impl.EngineCharacterEntity;

/**
 * AI module for entity behavior
 */
class AIModule implements IModule {
    private var aiProfiles: Map<String, Dynamic>;
    
    public function new() {
        aiProfiles = new Map();
    }
    
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Only update AI every N ticks
        if (tick % NecrotonEngine.Config.aiUpdateInterval != 0) {
            return;
        }
        
        // Update AI for all entities
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive && entity.ownerId == "") { // AI entities have empty ownerId
                    updateEntityAI(entity, state, tick);
                }
            });
        }
    }
    
    public function shutdown(): Void {
        aiProfiles.clear();
    }
    
    /**
     * Register AI behavior profile
     * @param profileName Profile name
     * @param behavior Behavior configuration
     */
    public function registerProfile(profileName: String, behavior: Dynamic): Void {
        aiProfiles.set(profileName, behavior);
    }
    
    private function updateEntityAI(entity: Dynamic, state: GameModelState, tick: Int): Void {
        // Simple AI behavior - random movement
        if (entity.type == EntityType.CHARACTER) {
            final character = cast(entity, EngineCharacterEntity);
            
            if (character.aiProfile != "" && aiProfiles.exists(character.aiProfile)) {
                final profile = aiProfiles.get(character.aiProfile);
                applyAIBehavior(character, profile, state);
            } else {
                // Default wander behavior
                wanderBehavior(character, state);
            }
        }
    }
    
    private function applyAIBehavior(character: Dynamic, profile: Dynamic, state: GameModelState): Void {
        // Apply specific AI behavior based on profile
        // This is a stub implementation
    }
    
    private function wanderBehavior(character: Dynamic, state: GameModelState): Void {
        // Simple wander behavior - random movement
        if (state.rng.nextFloat() < 0.1) { // 10% chance to change direction
            final angle = state.rng.nextFloatRange(0, Math.PI * 2);
            final speed = 50.0; // pixels per second
            
            character.vel = {
                x: Math.cos(angle) * speed,
                y: Math.sin(angle) * speed
            };
        }
    }
}
