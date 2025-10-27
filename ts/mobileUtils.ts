class MobileUtils {
    public test() {
        console.log('test from TS!');
    }

    public requestFullscreen(): void {
        const elem = document.documentElement;
        if (elem.requestFullscreen) {
            elem.requestFullscreen();
        } else if ((elem as any).webkitRequestFullscreen) {
            (elem as any).webkitRequestFullscreen();
        } else if ((elem as any).msRequestFullscreen) {
            (elem as any).msRequestFullscreen();
        }
    }

    public getDeviceInfo(): any {
        return {
            userAgent: navigator.userAgent,
            platform: navigator.platform,
            devicePixelRatio: window.devicePixelRatio,
            screenWidth: screen.width,
            screenHeight: screen.height,
            windowWidth: window.innerWidth,
            windowHeight: window.innerHeight,
            isTouch: 'ontouchstart' in window,
        };
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const mobileUtils = new MobileUtils();
    
    // Make it globally accessible for debugging
    (window as any).mobileUtils = mobileUtils;
    
    console.log('Device Info:', mobileUtils.getDeviceInfo());
});

// Export as default for ES modules
export default MobileUtils;