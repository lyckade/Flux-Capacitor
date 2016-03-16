# out: ../lib/conf.js

CSON = require "season"

module.exports =
class Conf

  constructor: ->
    @CSON = CSON
    @suffix = ".cson"
    @confFiles = []

  reload: ->
    for confFileName in @confFiles
      @loadFile confFileName

  load: (confFileName) ->
    @addFile confFileName
    @loadFile confFileName

  addFile: (confFileName) ->
    if confFileName not in @confFiles
      @confFiles.push confFileName

  loadFile: (confFileName) ->
    @[confFileName] = @CSON.readFileSync @makeFilePath confFileName

  write: (confFileName, dataObj) ->
    @CSON.writeFileSync @makeFilePath confFileName, dataObj

  makeFilePath: (confFileName) ->
    "./conf/#{confFileName}#{@suffix}"
