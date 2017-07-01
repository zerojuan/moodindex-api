const path = require( 'path' );

module.exports = {
	entry: './src/index.js',
	target: 'node',
	output: {
		path: './dist',
		filename: 'index.js',
		libraryTarget: 'commonjs2'
	},
	externals: {
    // AWS does it's own unpacking that breaks webpack
		'aws-sdk': 'aws-sdk'
	},
  resolve: {
    alias: {
      // So that lambda functions can import "Lib/..." instead of relative pathing
      Lib: path.resolve( __dirname, './lib' )
    }
  },
	module: {
		loaders: [
		{
			test: /\.js$/,
			loader: 'babel',
			exclude: [/node_modules/]
		},
		{
			test: /\.json$/,
			loader: 'json-loader'
		}
		]
	}
}
