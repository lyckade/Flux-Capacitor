fs = require "fs-extra"
path = require "path"
_ = require "underscore"
FileSync = require "./filesync"

class FolderSync
  constructor: (options = {}) ->
    defaultOptions =
      FileSync: FileSync.options
    @options = _.defaults options, defaultOptions

  sync: (srcFolder, dstFolder, options = {}) ->
    syncOptions = _.defaults options, @options
    items = []
    fs.walk(srcFolder)
    .on('data', (item) ->
      if item.stats.isFile()
        FileSync.sync item.path, @makeDstPath(item.path), FolderSync.options.FileSync
        #console.log @makeDstPath item.path
    )
    #.on('end', ->
    #  return items)

  makeDstPath: (srcFolder, dstFolder, filePath) ->
    wayToSrcRoot = path.relative srcFolder, filePath
    path.join dstFolder, wayToSrcRoot


module.exports = new FolderSync
