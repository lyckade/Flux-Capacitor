# out: ../lib/conf.js

CSON = require "season"

module.exports =
class Conf

  constructor: ->
    @CSON = CSON
    @suffix = ".cson"

  load: (confFileName) ->
    @CSON.readFileSync @makeFilePath confFileName

  write: (confFileName, dataObj) ->
    @CSON.writeFileSync @makeFilePath confFileName, dataObj

  makeFilePath: (confFileName) ->
    "./conf/#{confFileName}#{@suffix}"
