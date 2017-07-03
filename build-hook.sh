#!/bin/bash

echo "Building $cwd"
../../node_modules/.bin/webpack --config ../../webpack.config.js --bail
