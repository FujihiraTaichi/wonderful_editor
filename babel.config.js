module.exports = function (api) {
  const env = api.env();
  const isTest = env === 'test';
  const isProd = env === 'production';
  const isDev  = env === 'development';

  return {
    presets: [
      isTest && ['@babel/preset-env', { targets: { node: 'current' } }],
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

      // ★ 3兄弟の loose を必ず同一(true)にする
      ['@babel/plugin-transform-class-properties',           { loose: true }],
      ['@babel/plugin-transform-private-methods',            { loose: true }],
      ['@babel/plugin-transform-private-property-in-object', { loose: true }],

      ['@babel/plugin-transform-object-rest-spread', { useBuiltIns: true }],
      ['@babel/plugin-transform-runtime', { helpers: true, regenerator: true, corejs: false }],
    ].filter(Boolean),
  };
};