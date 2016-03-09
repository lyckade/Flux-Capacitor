# out: ../lib/dataflux.js

fse = require "fs-extra"
watch = require "watch"
_ = require "underscore"

timestamp = require "./timestamp"
pathHelper = require "./path-helper"


module.exports =
class Dataflux
  constructor: (@srcFolder, @dataFluxFolder, options) ->
    @ts = timestamp
    @path = pathHelper
    @fse = fse
    @watch = watch

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
    #console.log @options.timestamp
    #@ts.timestampElements = @options.timestamp.elements
    #@ts.timestampSeparator = @options.timestamp.separator

  watch: ->

  skipFile: (filePath) ->
    for pattern in @options.skipFile.patterns
      if filePath.match pattern
        return true
    return false

  copyFileVersion: (filePath) ->

  makeFileName: (filePath) ->
    fileStat = @fse.statSync filePath
    pathParse = @path.parse filePath
    "#{pathParse.name}.#{@makeTimestamp fileStat.mtime}#{pathParse.ext}"

  makeTimestamp: (dateObj) ->
    @ts.makeTimestamp(dateObj)
