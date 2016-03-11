# out: ../lib/log.js

dateformat = require "dateformat"

module.exports =
class Log

  constructor: ->
    @separator = "|"
    @dateformat = dateformat
    @dateformat.masks.log = "yyyy.mm.dd HH:MM:ss"
    @callbacks = [console.log]

  log: (txt, type="INFO") ->
    for cb in @callbacks
      cb @makeLogLine txt, type

  makeLogLine: (txt, type="INFO") ->
    [@makeDateString(new Date), type, txt].join(@separator)

  makeDateString: (dateObj) ->
    @dateformat dateObj, "log"
