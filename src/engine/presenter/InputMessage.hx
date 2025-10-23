package engine.presenter;

/**
 * Input message structure
 */
typedef InputMessage = {
    var clientId: String;
    var sequence: Int;
    var clientTick: Int;
    var intendedServerTick: Int;
    var movement: {x: Float, y: Float};
    var actions: Array<Dynamic>;
    var timestamp: Float; // For debugging and timing analysis
}
