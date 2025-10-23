import { defineConfig } from 'vite'
import { copyFileSync } from 'fs'

export default defineConfig({
  // Entry point - your main HTML file
  root: '.',
  
  // Build configuration
  build: {
    // Output directory
    outDir: 'dist',
    // Keep the same structure as your current setup
    rollupOptions: {
      input: './index.html'
    },
    // Don't minify for easier debugging
    minify: false,
    // Source maps for debugging
    sourcemap: true
  },
  
  // Development server
  server: {
    port: 3000,
    open: true,
    cors: true
  },
  
  // TypeScript configuration
  esbuild: {
    target: 'es2015'
  },
  
  // Resolve configuration
  resolve: {
    alias: {
      // Make sure TypeScript files are resolved correctly
      '@': '/ts'
    }
  },
  
  // CSS configuration
  css: {
    devSourcemap: true
  },
  
  // Plugin to copy game.js after build
  plugins: [
    {
      name: 'copy-game-js',
      closeBundle() {
        try {
          copyFileSync('game.js', 'dist/game.js')
          console.log('✓ Copied game.js to dist/')
        } catch (err) {
          console.warn('Could not copy game.js:', err.message)
        }
      }
    }
  ]
})
