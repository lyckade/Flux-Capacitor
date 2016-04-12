# out: ../lib/conf.js

{EventEmitter} = require "events"
CSON = require "season"
_ = require "underscore"

fileexists = require "./fileexists"

module.exports =
class Conf extends EventEmitter

  constructor: ->
    @CSON = CSON
    @suffix = ".cson"
    @confFiles = []
    @defaultFiles =
      settings: 'defaultSettings'
    @fileexists = require "./fileexists"

  reload: ->
    for confFileName in @confFiles
      @loadFile confFileName
    @refreshCallback()

  load: (confFileName) ->
    @addFile confFileName
    @loadFile confFileName
    @refreshCallback()

  addFile: (confFileName) ->
    if confFileName not in @confFiles
      @confFiles.push confFileName

  loadFile: (confFileName) ->
    obj = confFileName
    if not @fileexists(@makeFilePath confFileName) and confFileName of @defaultFiles
      confFileName = @defaultFiles[confFileName]
    @[obj] = @CSON.readFileSync @makeFilePath confFileName

  refreshCallback: ->
    @emit "loaded"

  write: (confFileName, confObj) ->
    if confObj is undefined
      confObj = @[confFileName]
    @CSON.writeFileSync @makeFilePath(confFileName), confObj

  removeHashKeyFromArray: (confArray) ->
    outArray = []
    for item in confArray
      outArray.push(_.omit item, "$$hashKey")
    outArray

  makeFilePath: (confFileName) ->
    "./conf/#{confFileName}#{@suffix}"
