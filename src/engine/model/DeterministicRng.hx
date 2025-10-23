package engine.model;

/**
 * Deterministic seeded random number generator
 */
class DeterministicRng {
    public var seed: Int;
    private var state: Int;
    
    public function new(seed: Int) {
        this.seed = seed;
        this.state = seed;
    }
    
    /**
     * Generate next random integer
     * @return Random integer
     */
    public function nextInt(): Int {
        state = (state * 1103515245 + 12345) & 0x7fffffff;
        return state;
    }
    
    /**
     * Generate random float between 0 and 1
     * @return Random float
     */
    public function nextFloat(): Float {
        return nextInt() / 2147483647.0;
    }
    
    /**
     * Generate random float in range
     * @param min Minimum value
     * @param max Maximum value
     * @return Random float in range
     */
    public function nextFloatRange(min: Float, max: Float): Float {
        return min + nextFloat() * (max - min);
    }
    
    /**
     * Generate random integer in range
     * @param min Minimum value (inclusive)
     * @param max Maximum value (exclusive)
     * @return Random integer in range
     */
    public function nextIntRange(min: Int, max: Int): Int {
        return min + (nextInt() % (max - min));
    }
    
    /**
     * Clone RNG with same state
     * @return Cloned RNG
     */
    public function clone(): DeterministicRng {
        final cloned = new DeterministicRng(seed);
        cloned.state = state;
        return cloned;
    }
    
    /**
     * Serialize RNG state
     * @return Serialized state
     */
    public function serialize(): Dynamic {
        return {
            seed: seed,
            state: state
        };
    }
    
    /**
     * Deserialize RNG state
     * @param data Serialized state
     */
    public function deserialize(data: Dynamic): Void {
        seed = data.seed;
        state = data.state;
    }
}
