# out: ../lib/path-helper.js

path = require "path"

module.exports =
class PathHelper
  constructor: ->
    @path = path

  makePath: (srcFolder, dstFolder, filePath) ->
    wayToSrcRoot = @path.relative srcFolder, filePath
    @path.join dstFolder, wayToSrcRoot
