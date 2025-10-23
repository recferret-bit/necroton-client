package engine.presenter;

import engine.presenter.InputMessage;

/**
 * Per-client input buffer
 */
class InputBuffer {
    private var inputs: Array<InputMessage>;
    
    public function new() {
        inputs = [];
    }
    
    /**
     * Push input to buffer
     * @param input Input message
     */
    public function push(input: InputMessage): Void {
        inputs.push(input);
        
        // Keep sorted by intendedServerTick
        inputs.sort(function(a, b) {
            if (a.intendedServerTick != b.intendedServerTick) {
                return a.intendedServerTick - b.intendedServerTick;
            }
            return a.sequence - b.sequence;
        });
    }
    
    /**
     * Collect inputs for specific tick
     * @param tick Target tick
     * @return Array of inputs for this tick
     */
    public function collectForTick(tick: Int): Array<InputMessage> {
        final result = [];
        final toRemove = [];
        
        for (i in 0...inputs.length) {
            final input = inputs[i];
            if (input.intendedServerTick == tick) {
                result.push(input);
                toRemove.push(i);
            } else if (input.intendedServerTick > tick) {
                break; // Sorted, so no more inputs for this tick
            }
        }
        
        // Remove collected inputs (in reverse order to maintain indices)
        var i = toRemove.length - 1;
        while (i >= 0) {
            inputs.splice(toRemove[i], 1);
            i--;
        }
        
        return result;
    }
    
    /**
     * Drop inputs up to sequence
     * @param sequence Last acknowledged sequence
     */
    public function dropUpToSequence(sequence: Int): Void {
        final toRemove = [];
        
        for (i in 0...inputs.length) {
            if (inputs[i].sequence <= sequence) {
                toRemove.push(i);
            }
        }
        
        // Remove in reverse order
        for (i in toRemove.length - 1...-1) {
            inputs.splice(toRemove[i], 1);
        }
    }
}