fs = require "fs-extra"
path = require "path"
_ = require "underscore"
FileSync = require "./filesync"

module.exports =
class FolderSync
  constructor: (options = {}) ->
    @path = path
    @fs = fs
    @FileSync = new FileSync
    defaultOptions =
      FileSync: @FileSync.options
      skipItem:
        patterns: []
    @options = _.defaults options, defaultOptions


  sync: (srcFolder, dstFolder, options = {}) ->
    syncOptions = _.defaults options, @options
    items = []
    @fs.walk(srcFolder)
    .on('data', (item) ->
      if not @skipItem item, syncOptions.skipItem
        @FileSync.sync item.path, @makeDstPath(item.path), syncOptions.FileSync
        #console.log @makeDstPath item.path
    )
    #.on('end', ->
    #  return items)

  skipItem: (item, options) ->
    if item.isDirectory()
      return true
    for pattern in options.patterns
      if item.path.match(pattern)
        return true
    return false


  makeDstPath: (srcFolder, dstFolder, filePath) ->
    wayToSrcRoot = @path.relative srcFolder, filePath
    @path.join dstFolder, wayToSrcRoot
