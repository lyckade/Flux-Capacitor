# out: ../lib/path-helper.js

path = require "path"

module.exports = path

module.exports.makePath = (srcFolder, dstFolder, filePath) ->
  wayToSrcRoot = path.relative srcFolder, filePath
  path.join dstFolder, wayToSrcRoot

module.exports.isSubfolder = (folder, checkFolder) ->
  rel = path.relative folder, checkFolder
  if rel[0...2] is ".."
    return false
  else
    return true
