package engine.view;

/**
 * Event bus implementation with ordered delivery and safe async dispatch
 */
class EventBus implements IEventBus {
    private var subscribers: Map<String, Array<{token: Int, handler: Dynamic->Void}>>;
    private var nextToken: Int;
    private var eventQueue: Array<{topic: String, payload: Dynamic}>;
    private var isProcessing: Bool;
    
    public function new() {
        subscribers = new Map();
        nextToken = 1;
        eventQueue = [];
        isProcessing = false;
    }
    
    public function subscribe<T>(topic: String, handler: T->Void): Int {
        if (!subscribers.exists(topic)) {
            subscribers.set(topic, []);
        }
        
        final token = nextToken++;
        // Wrap typed handler in dynamic handler for internal storage
        final dynamicHandler: Dynamic->Void = function(payload: Dynamic): Void {
            handler(cast payload);
        };
        subscribers.get(topic).push({token: token, handler: dynamicHandler});
        return token;
    }
    
    public function subscribeDynamic(topic: String, handler: Dynamic->Void): Int {
        if (!subscribers.exists(topic)) {
            subscribers.set(topic, []);
        }
        
        final token = nextToken++;
        subscribers.get(topic).push({token: token, handler: handler});
        return token;
    }
    
    public function unsubscribe(token: Int): Void {
        for (topic in subscribers.keys()) {
            final subs = subscribers.get(topic);
            for (i in 0...subs.length) {
                if (subs[i].token == token) {
                    subs.splice(i, 1);
                    return;
                }
            }
        }
    }
    
    public function emit(topic: String, payload: Dynamic): Void {
        // Queue event for safe async dispatch
        eventQueue.push({topic: topic, payload: payload});
        
        // Process queue if not already processing
        if (!isProcessing) {
            processEventQueue();
        }
    }
    
    private function processEventQueue(): Void {
        isProcessing = true;
        
        while (eventQueue.length > 0) {
            final event = eventQueue.shift();
            final subs = subscribers.get(event.topic);
            
            if (subs != null) {
                // Create copy to avoid issues if handlers modify the array
                final handlers = subs.copy();
                for (sub in handlers) {
                    try {
                        sub.handler(event.payload);
                    } catch (e: Dynamic) {
                        // Log error but continue processing other handlers
                        trace('Event handler error: ' + e);
                    }
                }
            }
        }
        
        isProcessing = false;
    }
}
