// Type definitions for game integration

interface Window {
    gameInit?: () => void;
    onGameTouch?: (x: number, y: number) => void;
    customTouchHandler?: (x: number, y: number) => void;
}

interface TouchData {
    x: number;
    y: number;
    timestamp: number;
}

interface GameConfig {
    enableAnalytics: boolean;
    debugMode: boolean;
    soundEnabled: boolean;
    vibrationEnabled: boolean;
}

export { TouchData, GameConfig };