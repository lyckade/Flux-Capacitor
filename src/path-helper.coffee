# out: ../lib/path-helper.js

path = require "path"


module.exports.makePath = (srcFolder, dstFolder, filePath) ->
  wayToSrcRoot = path.relative srcFolder, filePath
  path.join dstFolder, wayToSrcRoot
