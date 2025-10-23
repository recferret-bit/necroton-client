package engine.view;

/**
 * Event bus contract for publishing and subscribing to events
 */
interface IEventBus {
    /**
     * Subscribe to events on a topic with typed handler
     * @param topic Event topic (e.g., "entity:spawn", "physics:contact")
     * @param handler Function to call when event is emitted
     * @return Subscription token for unsubscribing
     */
    function subscribe<T>(topic: String, handler: T->Void): Int;
    
    /**
     * Subscribe to events on a topic with dynamic handler (legacy support)
     * @param topic Event topic (e.g., "entity:spawn", "physics:contact")
     * @param handler Function to call when event is emitted
     * @return Subscription token for unsubscribing
     */
    function subscribeDynamic(topic: String, handler: Dynamic->Void): Int;
    
    /**
     * Unsubscribe from events using token
     * @param token Token returned from subscribe()
     */
    function unsubscribe(token: Int): Void;
    
    /**
     * Emit an event to all subscribers
     * @param topic Event topic
     * @param payload Event data
     */
    function emit(topic: String, payload: Dynamic): Void;
}
