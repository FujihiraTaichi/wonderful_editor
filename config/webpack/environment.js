const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)

// ▼ babel-loader が node_modules を触らないように明示
const babelLoader = environment.loaders.get('babel')
if (babelLoader) {
  babelLoader.exclude = /node_modules/
}

// （任意）ESM を優先しない設定にしておくと古い依存でも安定しやすい
environment.config.merge({
  resolve: {
    mainFields: ['browser', 'main'] // 'module' は後回し
  }
})

module.exports = environment
