// Main entry point for Vite bundling
import './mobileUtils';
import MobileUtils from './mobileUtils';

export { default as MobileUtils } from './mobileUtils';

// Initialize mobile utils when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const mobileUtils = new MobileUtils();
    
    // Make it globally accessible for debugging
    (window as any).mobileUtils = mobileUtils;
    
    console.log('Device Info:', mobileUtils.getDeviceInfo());
    
    // Test the mobile utils
    mobileUtils.test();
    
    // Ensure WebGL context is properly initialized
    const canvas = document.getElementById('webgl') as HTMLCanvasElement;
    if (canvas) {
        console.log('Canvas found:', canvas);
        
        // Check if WebGL is supported
        const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
        if (gl) {
            console.log('WebGL context created successfully');
        } else {
            console.error('WebGL not supported');
        }
    } else {
        console.error('Canvas element not found');
    }
});
