import { defineConfig } from 'vite'
import { copyFileSync, readFileSync, writeFileSync, unlinkSync } from 'fs'
import { execSync } from 'child_process'

export default defineConfig(({ command, mode }) => {
  const isProduction = mode === 'production'
  
  return {
    // Entry point - your main HTML file
    root: '.',
    
    // Build configuration
    build: {
      // Output directory
      outDir: 'dist',
      // Configure output for production builds
      rollupOptions: {
        input: './index.html',
        output: isProduction ? {
          // For production, generate bundle.min.js in dist root
          entryFileNames: 'bundle.min.js',
          chunkFileNames: 'assets/[name]-[hash].js',
          assetFileNames: 'assets/[name]-[hash].[ext]'
        } : undefined
      },
      // Minify for production, don't minify for dev
      minify: isProduction ? 'terser' : false,
      terserOptions: isProduction ? {
        compress: {
          drop_console: true,
          drop_debugger: true,
          pure_funcs: ['console.log']
        },
        mangle: true,
        format: {
          comments: false
        }
      } : undefined,
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
            let gameJsContent = readFileSync('game.js', 'utf8')
            
            // Find the main bundle file
            const mainBundleFile = Object.keys(bundle).find(key => 
              bundle[key].type === 'chunk' && bundle[key].isEntry
            )
            
            if (mainBundleFile) {
              // If this is a production build, minify the game.js content
              if (isProduction) {
                try {
                  // Write game.js content to a temp file
                  const tempFile = 'temp_game.js'
                  writeFileSync(tempFile, gameJsContent)
                  
                  // Use terser to minify it
                  execSync(`npx terser ${tempFile} --output ${tempFile}.min --compress --mangle --comments false`, { stdio: 'pipe' })
                  
                  // Read the minified content
                  gameJsContent = readFileSync(`${tempFile}.min`, 'utf8')
                  
                  // Clean up temp files
                  unlinkSync(tempFile)
                  unlinkSync(`${tempFile}.min`)
                  
                  console.log('✓ Minified game.js content')
                } catch (minifyErr) {
                  console.warn('Could not minify game.js:', minifyErr.message)
                }
              }
              
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
              // Read the original index.html
              let indexContent = readFileSync('index.html', 'utf8')
              
              // Replace the TypeScript module script with bundle.min.js for production
              indexContent = indexContent.replace(
                '<script type="module" src="/dist/main.js"></script>',
                '<script type="text/javascript" src="./bundle.min.js"></script>'
              )
              
              // Remove the separate game.js script tag since it's now bundled
              indexContent = indexContent.replace(
                '<script type="text/javascript" src="./game.js"></script>',
                ''
              )
              
              // Write it as index.html in the dist folder
              writeFileSync('dist/index.html', indexContent)
              console.log('✓ Generated production index.html with bundle.min.js')
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
              // List of files to remove after bundling
              const filesToRemove = [
                'dist/bundle.js',
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
