import { defineConfig } from 'vite'
import { copyFileSync, readFileSync, writeFileSync } from 'fs'

export default defineConfig(({ command, mode }) => {
  const isProduction = mode === 'production'
  
  return {
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
      // Minify for production, don't minify for dev
      minify: isProduction,
      // Source maps for debugging
      sourcemap: !isProduction,
      // Don't clean the dist directory for production builds
      emptyOutDir: !isProduction
    },
    
    // Development server
    server: {
      port: 3000,
      open: true,
      cors: true,
      // Serve TypeScript files as JavaScript
      middlewareMode: false,
      fs: {
        allow: ['..']
      }
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
      devSourcemap: !isProduction
    },
    
    // Plugin to copy game.js and generate production index.html
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
      },
      {
        name: 'compile-typescript',
        configureServer(server) {
          server.middlewares.use('/dist', (req, res, next) => {
            // If requesting main.js, compile TypeScript on the fly
            if (req.url === '/main.js') {
              try {
                const { execSync } = require('child_process')
                execSync('tsc --project tsconfig.build.json', { stdio: 'inherit' })
                console.log('✓ Compiled TypeScript for development')
              } catch (err) {
                console.warn('TypeScript compilation failed:', err.message)
              }
            }
            next()
          })
        }
      },
      {
        name: 'generate-prod-index',
        closeBundle() {
          if (isProduction) {
            try {
              // Read the original index.html
              let indexContent = readFileSync('index.html', 'utf8')
              
              // Replace the TypeScript module script with bundle.min.js for production
              indexContent = indexContent.replace(
                '<script type="module" src="/dist/main.js"></script>',
                '<script type="module" src="./bundle.min.js"></script>'
              )
              
              // Write it as index.html in the dist folder
              writeFileSync('dist/index.html', indexContent)
              console.log('✓ Generated production index.html with bundle.min.js')
            } catch (err) {
              console.warn('Could not generate production index.html:', err.message)
            }
          }
        }
      }
    ]
  }
})
