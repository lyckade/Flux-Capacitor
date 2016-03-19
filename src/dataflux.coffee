# out: ../lib/dataflux.js

fse = require "fs-extra"
watch = require "watch"
_ = require "underscore"

fileExists = require "./fileexists"
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
    @fileExists = fileExists
    defaultOptions =
      skipFile:
        patterns: []
      autoFlushInterval: 10000
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

  autoFlush: ->
    @log.debug "autoFlush method called"
    setInterval =>
      @log.debug "Call flushBackupCache()"
      @flushBackupCache()
    , @options.autoFlushInterval

  watch: ->
    @watcher.createMonitor @srcFolder, (monitor) =>
      monitor.on "created", (f, stat) =>
        @log.debug "#{f} is new"
        @addFileForBackup f
      monitor.on "changed", (f, curr, prev) =>
        @log.debug "#{f} has changed"
        @addFileForBackup f
      monitor.on "removed", (f, stat) =>
        @log.debug "#{f} was removed"

  addFileForBackup: (filePath) ->
    if filePath not in @backupCache and not @skipFile filePath
      @backupCache.push filePath

  skipFile: (filePath) ->
    for pattern in @options.skipFile.patterns
      if filePath.match pattern
        return true
    if @isDirectory filePath
      return true
    else if @isFluxFile filePath
      return true
    return false

  isFluxFile: (filePath) ->
    rel = @path.relative @dataFluxFolder, filePath
    if rel[0...2] is ".."
      return false
    else
      return true

  isDirectory: (filePath) ->
    @fse.lstatSync(filePath).isDirectory()

  flushBackupCache: ->
    for filePath in @backupCache
      @copyFileVersion filePath
    @log.debug "Backup cache has been flushed"
    @backupCache = []

  copyFileVersion: (filePath) ->
    if @isFluxFile filePath
      throw new Error "#{filePath} is part of the FluxFolder"
    else if @fileExists filePath
      fluxPath = @makeFluxPath filePath
      @fse.copySync(filePath, fluxPath)
      @log.log "#{filePath} copied to #{fluxPath}"
    else
      @log.notice "#{filePath} does not exist anymore"

  makeFluxPath: (filePath) ->
    @path.makePath @srcFolder, @dataFluxFolder, @addTimestamp filePath

  addTimestamp: (filePath) ->
    fileStat = @fse.statSync filePath
    pathParse = @path.parse filePath
    fileName ="#{pathParse.name}.#{@makeTimestamp fileStat.mtime}#{pathParse.ext}"
    @path.join pathParse.dir, fileName

  makeTimestamp: (dateObj) ->
    @ts.makeTimestamp(dateObj)
