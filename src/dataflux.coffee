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
    @watcher = watch
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
    @autoFlushIntervall = 1000
    @autoFlush = ->
      setInterval =>
        @flushBackupCache()
      , @autoFlushIntervall

  watch: =>
    @watcher.watchTree @srcFolder, (f, curr, prev) =>
      if typeof f is "object" and prev is null and curr is null
        @log.debug "Listeners for #{@srcFolder} tree are ready."
      else if typeof f isnt "object" and prev is null
        @log.debug "#{f} is new"
        @addFileForBackup f
      else if typeof f isnt "object" and curr.nlink is null
        @log.debug "#{f} was removed"
      else if typeof f isnt "object" and curr isnt null and prev isnt null
        @log.debug "#{f} has changed"
        @addFileForBackup f

  addFileForBackup: (filePath) ->
    if filePath not in @backupCache and not @skipFile filePath
      @backupCache.push filePath

  skipFile: (filePath) ->
    for pattern in @options.skipFile.patterns
      if filePath.match pattern
        return true
      else if @isDirectory filePath
        return true
    return false

  isDirectory: (filePath) ->
    @fse.lstatSync(filePath).isDirectory()

  flushBackupCache: ->
    for filePath in @backupCache
      @copyFileVersion filePath
    @log.debug "Backup cache has been flushed"
    @backupCache = []

  copyFileVersion: (filePath) ->
    fluxPath = @makeFluxPath filePath
    @fse.copySync(filePath, fluxPath)
    @log.log "#{filePath} copied to #{fluxPath}"

  makeFluxPath: (filePath) ->
    @path.makePath @srcFolder, @dataFluxFolder, @addTimestamp filePath

  addTimestamp: (filePath) ->
    fileStat = @fse.statSync filePath
    pathParse = @path.parse filePath
    fileName ="#{pathParse.name}.#{@makeTimestamp fileStat.mtime}#{pathParse.ext}"
    @path.join pathParse.dir, fileName

  makeTimestamp: (dateObj) ->
    @ts.makeTimestamp(dateObj)
