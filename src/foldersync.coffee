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
      justBackup: false
      skipItem:
        patterns: []
    @options = _.defaults options, defaultOptions
    @options.FileSync.justBackup = @options.justBackup
    @srcFolder = null
    @dstFolder = null

  sync: (srcFolder, dstFolder, options = {}) ->
    @syncOptions = _.defaults options, @options
    @srcFolder = srcFolder
    @dstFolder = dstFolder
    @walk srcFolder, @syncItem, "src"
    if not @syncOptions.justBackup
      @walk dstFolder, @syncItem, "dst"

  walk: (folder, callback, walktype="src") =>
    @fs.walk(folder)
    .on("data", (item) ->
      callback item, walktype)

  syncItem: (item, walktype) =>
    if not @skipItem item, @options.skipItem
      if walktype is "src"
        @FileSync.sync item.path, @makeDstPath(item.path), @syncOptions.FileSync
      if walktype is "dst"
        options = @syncOptions.FileSync
        options.justNewFiles = true
        @FileSync.sync item.path, @makeSrcPath(item.path), options

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
