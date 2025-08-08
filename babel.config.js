module.exports = function (api) {
  const validEnv = ['development', 'test', 'production']
  const currentEnv = api.env()
  const isDev = api.env('development')
  const isProd = api.env('production')
  const isTest = api.env('test')

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid NODE_ENV/BABEL_ENV: "development" | "test" | "production". ' +
      `Received: ${JSON.stringify(currentEnv)}.`
    )
  }

  return {
    presets: [
      isTest && [
        '@babel/preset-env',
        { targets: { node: 'current' } }
      ],
      (isProd || isDev) && [
        '@babel/preset-env',
        {
          forceAllTransforms: true,
          useBuiltIns: 'entry',
          corejs: 3,
          modules: false,
          exclude: ['transform-typeof-symbol'],
        },
      ],
    ].filter(Boolean),
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTest && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',

      // ▼ ここを “proposal” → “transform” に置き換え
      ['@babel/plugin-transform-class-properties', { loose: true }],
      ['@babel/plugin-transform-object-rest-spread', { useBuiltIns: true }],
      ['@babel/plugin-transform-private-methods', { loose: true }],
      ['@babel/plugin-transform-private-property-in-object', { loose: true }],

      ['@babel/plugin-transform-runtime', { helpers: false }],
      ['@babel/plugin-transform-regenerator', { async: false }],
    ].filter(Boolean),
  }
}