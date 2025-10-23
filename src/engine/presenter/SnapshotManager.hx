package engine.presenter;

import engine.model.GameModelState;

/**
 * Circular buffer for storing game state snapshots
 */
class SnapshotManager {
    private var snapshots: Array<{tick: Int, memento: GameStateMemento}>;
    private var maxSize: Int;
    private var head: Int;
    private var count: Int;
    
    public function new(maxSize: Int) {
        this.maxSize = maxSize;
        snapshots = [];
        head = 0;
        count = 0;
    }
    
    /**
     * Store snapshot for tick
     * @param tick Tick number
     * @param memento Game state memento
     */
    public function store(tick: Int, memento: GameStateMemento): Void {
        final snapshot = {tick: tick, memento: memento};
        
        if (count < maxSize) {
            snapshots.push(snapshot);
            count++;
        } else {
            snapshots[head] = snapshot;
            head = (head + 1) % maxSize;
        }
    }
    
    /**
     * Load snapshot for tick
     * @param tick Tick number
     * @return Snapshot memento or null if not found
     */
    public function load(tick: Int): GameStateMemento {
        for (snapshot in snapshots) {
            if (snapshot.tick == tick) {
                return snapshot.memento;
            }
        }
        return null;
    }
    
    /**
     * Get latest tick
     * @return Latest tick number
     */
    public function latest(): Int {
        if (count == 0) return 0;
        
        var latestTick = 0;
        for (snapshot in snapshots) {
            if (snapshot.tick > latestTick) {
                latestTick = snapshot.tick;
            }
        }
        return latestTick;
    }
    
    /**
     * Purge snapshots before tick
     * @param tick Tick to purge before
     */
    public function purgeBefore(tick: Int): Void {
        final toRemove = [];
        for (i in 0...snapshots.length) {
            if (snapshots[i].tick < tick) {
                toRemove.push(i);
            }
        }
        
        // Remove in reverse order to maintain indices
        for (i in toRemove.length - 1...-1) {
            snapshots.splice(toRemove[i], 1);
            count--;
        }
    }
}
