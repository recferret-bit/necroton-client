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
    
    // Plugin to bundle game.js and generate production index.html
    plugins: [
      {
        name: 'bundle-game-js',
        generateBundle(options, bundle) {
          try {
            // Read game.js content
            const gameJsContent = readFileSync('game.js', 'utf8')
            
            // Find the main bundle file
            const mainBundleFile = Object.keys(bundle).find(key => 
              bundle[key].type === 'chunk' && bundle[key].isEntry
            )
            
            if (mainBundleFile) {
              // Prepend game.js content to the main bundle
              bundle[mainBundleFile].code = gameJsContent + '\n' + bundle[mainBundleFile].code
              console.log('✓ Bundled game.js into main bundle')
            }
          } catch (err) {
            console.warn('Could not bundle game.js:', err.message)
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
        writeBundle(options, bundle) {
          if (isProduction) {
            try {
              // Find the main bundled asset file
              const mainAssetFile = Object.keys(bundle).find(key => 
                bundle[key].type === 'chunk' && bundle[key].isEntry
              )
              
              if (mainAssetFile) {
                // Read the original index.html
                let indexContent = readFileSync('index.html', 'utf8')
                
                // Replace the TypeScript module script with the bundled asset for production
                indexContent = indexContent.replace(
                  '<script type="module" src="/dist/main.js"></script>',
                  `<script type="text/javascript" src="./${mainAssetFile}"></script>`
                )
                
                // Remove the separate game.js script tag since it's now bundled
                indexContent = indexContent.replace(
                  '<script type="text/javascript" src="./game.js"></script>',
                  ''
                )
                
                // Write it as index.html in the dist folder
                writeFileSync('dist/index.html', indexContent)
                console.log(`✓ Generated production index.html with bundled asset: ${mainAssetFile}`)
              }
            } catch (err) {
              console.warn('Could not generate production index.html:', err.message)
            }
          }
        }
      },
      {
        name: 'cleanup-unnecessary-files',
        closeBundle() {
          if (isProduction) {
            try {
              const { unlinkSync } = require('fs')
              
              // List of files to remove after bundling
              const filesToRemove = [
                'dist/bundle.js',
                'dist/bundle.min.js', 
                'dist/main.js',
                'dist/main.js.map',
                'dist/mobileUtils.js',
                'dist/mobileUtils.js.map'
              ]
              
              filesToRemove.forEach(file => {
                try {
                  unlinkSync(file)
                  console.log(`✓ Removed unnecessary file: ${file}`)
                } catch (err) {
                  // File might not exist, which is fine
                }
              })
            } catch (err) {
              console.warn('Could not clean up unnecessary files:', err.message)
            }
          }
        }
      }
    ]
  }
})
