#!/usr/bin/env sh

# abort on errors
set -e

# create new vite project
npm init vite@latest vite-tailwind && cd vite-tailwind

# (optional) open editor
code .

# install vite dependencies
npm i

# install dev dependencies:
# - vitejs legacy browser support (IE11+) plugin
# - tailwind and postCSS dependencies
# - tailwind form plugin
npm i -D tailwindcss@latest postcss@latest autoprefixer@latest @vitejs/plugin-legacy@latest @tailwindcss/forms@latest

# generate tailwind and postcss config files
npx tailwindcss init -p

# ------------------------------------------------------------------
#
# configure build for production pipeline
#
# ------------------------------------------------------------------

# create vite config file
echo "// configuring for legacy browser support with supporting polyfills
// https://github.com/vitejs/vite/tree/main/packages/plugin-legacy
import legacy from '@vitejs/plugin-legacy';

// configuring for multi-page apps
// https://vitejs.dev/guide/build.html#multi-page-app
import { resolve } from 'path';
import { defineConfig } from 'vite';

module.exports = defineConfig({
  plugins: [
    legacy({
      targets: ['ie >= 11'],
      additionalLegacyPolyfills: ['regenerator-runtime/runtime'],
      polyfills: ['es/array/flat-map', 'es/array/some', 'es/array/from'],
      modernPolyfills: ['es/array/flat-map', 'es/array/some', 'es/array/from']
    })
  ],
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        sent: resolve(__dirname, 'sent.html')
      }
    }
  }
});
" > vite.config.js

# <todo> insert any config changes needed
# in tailwind.config.css:
# in vite.config.css:
# in src/index.css:

# ------------------------------------------------------------------
#
# build
#
# ------------------------------------------------------------------

# build targeting IE11+
npm run build

# ------------------------------------------------------------------
#
# verify
#
# ------------------------------------------------------------------

# preview site to test
npm run serve

# run html accessability checks
npx pa11y http://localhost:5000

# get more aria-specific information
npx a11y http://localhost:5000

# check ecmascript transpilation and polyfills
# expect: vite's legacy plugin use of import/export to confuse eslint
npx eslint --no-eslintrc --parser-options=ecmaVersion:5 dist/assets/**/*.js

# ------------------------------------------------------------------
#
# deploy
#
# ------------------------------------------------------------------

# use surge to host demo
surge dist --domain vite-tailwind-form.surge.sh

# teardown demo
surge dist teardown vite-tailwind-form.surge.sh