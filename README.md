# Haxe + Heaps.io Mobile Game Project

A mobile-focused game project built with Haxe and Heaps.io, featuring TypeScript integration for custom JavaScript functionality.

## Prerequisites

Before you can build and run this project, you need to install:

1. **Haxe** (version 4.0+)
   - Download from: https://haxe.org/download/
   - Add to your system PATH

2. **Heaps.io library**
   ```bash
   haxelib install heaps
   ```

3. **TypeScript** (optional, for custom scripts)
   ```bash
   npm install -g typescript
   ```

## Project Structure

```
client/
├── src/                    # Haxe source files
│   └── Main.hx            # Main game application
├── ts/                     # TypeScript source files  
│   ├── types.ts           # Type definitions
│   └── mobileUtils.ts     # Mobile utility functions
├── bin/                   # Compiled output
├── assets/                # Game assets (images, sounds, etc.)
├── build.hxml             # Main build configuration
├── build-debug.hxml       # Debug build configuration  
├── build-release.hxml     # Release build configuration
├── tsconfig.json          # TypeScript configuration
├── build.ps1              # PowerShell build script
└── index.html             # Mobile-optimized HTML template
```

## Building the Project

### Using the Build Script (Recommended)

For debug build:
```powershell
.\build.ps1
```

For release build:
```powershell
.\build.ps1 -Mode release
```

### Manual Build

1. Compile TypeScript (if available):
   ```bash
   tsc
   ```

2. Compile Haxe:
   ```bash
   # Debug build
   haxe build-debug.hxml
   
   # Release build  
   haxe build-release.hxml
   ```

## Running the Project

1. Build the project using one of the methods above
2. Open `index.html` in a web browser
3. For mobile testing, use browser developer tools to simulate mobile devices
4. For real mobile testing, serve the files via a local web server

### Local Web Server Options

**Python 3:**
```bash
python -m http.server 8000
```

**Node.js (http-server):**
```bash
npx http-server -p 8000
```

**PHP:**
```bash
php -S localhost:8000
```

Then visit: `http://localhost:8000`

## Mobile Features

This project includes several mobile-optimized features:

### HTML Template
- Responsive viewport settings
- Mobile-specific meta tags
- Touch-optimized styles
- High DPI display support
- Loading screen with spinner
- Debug information overlay

### Haxe/Heaps.io Features
- Mobile-friendly engine settings
- Touch/click event handling
- High DPI canvas scaling
- Automatic layout updates
- Integration hooks for custom JavaScript

### TypeScript Integration
- Mobile utility functions
- Touch history tracking
- Device orientation handling
- Battery status monitoring
- Vibration feedback
- Visibility change handling
- Device information collection

## Mobile Testing

### Browser Testing
1. Open Chrome/Firefox Developer Tools
2. Toggle device simulation
3. Test various device sizes and orientations
4. Check touch events in console

### Real Device Testing
1. Serve the project on your local network
2. Find your IP address: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)  
3. Visit `http://YOUR_IP:8000` on your mobile device
4. Add to home screen for standalone app experience

## Development Tips

### Debug Mode
- Debug information is shown when running from localhost
- Console logs show touch events, orientation changes, etc.
- FPS counter and touch coordinates are displayed

### Custom Scripts
- Add TypeScript files to the `ts/` folder
- Use the global `mobileUtils` object for mobile-specific functionality
- Hook into game events via the global callback functions

### Asset Management
- Place game assets in the `assets/` folder
- Reference them in Haxe using the heaps resource system
- Optimize images for mobile (consider file sizes and formats)

## Configuration

### Build Settings
- Modify `build.hxml` for general build settings
- Use `build-debug.hxml` for development
- Use `build-release.hxml` for production builds

### TypeScript Settings
- Configure compilation in `tsconfig.json`
- Output goes to `bin/customScripts.js`
- Source maps are enabled for debugging

### Mobile Settings
- Viewport and PWA settings in `index.html`
- Mobile-specific styles in the embedded CSS
- Touch behavior configured in JavaScript

## Troubleshooting

### Common Issues

1. **Haxe not found**
   - Install Haxe from the official website
   - Ensure it's in your system PATH

2. **Heaps library missing**
   - Run: `haxelib install heaps`

3. **TypeScript compilation errors**
   - Install TypeScript globally: `npm install -g typescript`
   - Check `tsconfig.json` settings

4. **Game not loading on mobile**
   - Check browser console for errors
   - Ensure you're serving over HTTP (not file://)
   - Test on different devices/browsers

5. **Touch events not working**
   - Check if the canvas element is receiving events
   - Verify mobile-specific CSS is not interfering
   - Test with browser developer tools first

### Performance Tips
- Use release builds for testing performance
- Optimize assets for mobile devices
- Monitor battery usage on real devices
- Test on lower-end devices when possible

## License

This project template is provided as-is for educational and development purposes.