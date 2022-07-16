const path = require('path')

module.exports = {
  mode: 'development',
  entry: './tsx/index.tsx',
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader'
        ]
      },
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      },
      {
        test: /\.svg$/,
        loader: 'url-loader'
      }
    ]
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
    fallback: {
      'http': false
    }
  },
  output: {
    filename: 'index.js',
    path: path.resolve(__dirname, './js')
  }
}
