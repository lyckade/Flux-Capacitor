# out: ../lib/dataflux.js

fse = require "fs-extra"
watch = require "watch"
_ = require "underscore"

log = require "./logFactory"
timestamp = require "./timestamp"
pathHelper = require "./path-helper"


module.exports =
class Dataflux
  constructor: (@srcFolder, @dataFluxFolder, options = {}) ->
    @ts = timestamp
    @path = pathHelper
    @fse = fse
    @watch = watch
    @backupCache = []
    @log = log.makeLog()
    defaultOptions =
      skipFile:
        patterns: []
      timestamp:
        elements: [
          "yyyy"  # Year as 2015
          "mm"    # Month as 01
          "dd"    # Day as 03
          "HH"    # Hours
          "MM"    # Minutes
          "ss"    # Seconds
          ]
        separator: "-"
    @options = _.defaults options, defaultOptions
    @ts.timestampElements = @options.timestamp.elements
    @ts.timestampSeparator = @options.timestamp.separator

  watch: ->
    @watch.watchTree @srcFolder, (f, curr, prev) ->
      if typeof f is "object" and prev is null and curr is null
        @log.log "Listeners for #{@srcFolder} tree are ready."
      else if typeof f isnt "object" and prev is null
        @log.log "#{f} is new"
        @addFileForBackup f
      else if typeof f isnt "object" and curr.nlink is null
        @log.log "#{f} was removed"
      else if typeof f isnt "object" and curr isnt null and prev isnt null
        @log.log "#{f} has changed"
        @addFileForBackup f

  addFileForBackup: (filePath) ->
    if filePath not in @backupCache and not @skipFile filePath
      @backupCache.push filePath

  skipFile: (filePath) ->
    for pattern in @options.skipFile.patterns
      if filePath.match pattern
        return true
    return false

  flushBackupCache: ->
    for filePath in @backupCache
      @copyFileVersion filePath
    @log.log "Backup cache has been flushed"
    @backupCache = []

  copyFileVersion: (filePath) ->
    @fse.copySync(filePath, @makeFluxPath filePath)

  makeFluxPath: (filePath) ->
    @path.makePath @srcFolder, @dataFluxFolder, @addTimestamp filePath

  addTimestamp: (filePath) ->
    fileStat = @fse.statSync filePath
    pathParse = @path.parse filePath
    fileName ="#{pathParse.name}.#{@makeTimestamp fileStat.mtime}#{pathParse.ext}"
    @path.join pathParse.dir, fileName

  makeTimestamp: (dateObj) ->
    @ts.makeTimestamp(dateObj)
