package engine;

/**
 * Configuration for the Necroton Engine
 */
typedef EngineConfig = {
    /** Engine operational mode */
    var mode: EngineMode;
    
    /** Simulation tick rate (ticks per second) */
    var tickRate: Int;
    
    /** Unit size in pixels for all kinds of calculations */
    var unitPixels: Int;
    
    /** Ticks between AI updates */
    var aiUpdateInterval: Int;
    
    /** Circular buffer size for snapshots */
    var snapshotBufferSize: Int;
    
    /** Seed for deterministic RNG */
    var rngSeed: Int;
    
    /** Snapshot emission cadence for SERVER mode (every N ticks) */
    var snapshotEmissionInterval: Int;
}
