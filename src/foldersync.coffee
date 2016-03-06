# out: ../lib/foldersync.js

#fs = require "fs-extra"
path = require "path"
_ = require "underscore"
FileSync = require "./filesync"
pathHelper = require "./path-helper"

module.exports =
class FolderSync
  constructor: (options = {}) ->
    @path = path
    @fs = require "fs-extra"
    @FileSync = new FileSync
    @ph = new pathHelper()
    defaultOptions =
      FileSync: @FileSync.options
      skipItem:
        patterns: []
    @options = _.defaults options, defaultOptions
    @srcFolder = null
    @dstFolder = null

  sync: (srcFolder, dstFolder, options = {}) ->
    @syncOptions = _.defaults options, @options
    @srcFolder = srcFolder
    @dstFolder = dstFolder
    @walk srcFolder, @syncItem

  walk: (folder, callback) =>
    @fs.walk(folder)
    .on("data", (item) ->
      callback item)

  syncItem: (item) =>
    if not @skipItem item, @options.skipItem
      @FileSync.sync item.path, @makeDstPath(item.path), @syncOptions.FileSync

  skipItem: (item, options) ->
    try
      isDir = item.isDirectory()
      if isDir
        return true
    for pattern in options.patterns
      try
        skipPattern = item.path.match(pattern)
        if skipPattern
          return true
    return false

  makeDstPath: (filePath) ->
    @ph.makePath @srcFolder, @dstFolder, filePath

  makeSrcPath: (filePath) ->
    @ph.makePath @dstFolder, @srcFolder, filePath
