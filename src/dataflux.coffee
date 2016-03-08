# out: ../lib/dataflux.js

fse = require "fs-extra"

timestamp = require "./timestamp"
pathHelper = require "./path-helper"


module.exports =
class Dataflux
  constructor: (@srcFolder, @dataFluxFolder) ->
    @ts = timestamp
    @path = pathHelper
    @fse = fse

  makeFileName: (filePath) ->
    fileStat = @fse.statSync filePath
    pathParse = @path.parse filePath
    "#{pathParse.name}.#{@makeTimestamp fileStat.mtime}#{pathParse.ext}"

  makeTimestamp: (dateObj) ->
    @ts.makeTimestamp(dateObj)
