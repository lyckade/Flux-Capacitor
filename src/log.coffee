# out: ../lib/log.js

dateformat = require "dateformat"

module.exports =
class Log

  constructor: (options = {}) ->
    @separator = "|"
    @prefix = ""
    @noLog = false
    @debugModus = false

    @dateformat = dateformat
    @dateformat.masks.log = "yyyy.mm.dd HH:MM:ss"

    # A callback is just called via callback txt
    @callbacks = [@consoleCallback]

  debug: (txt) ->
    if @debugModus
      @log txt, "DEBUG"

  log: (txt, type="INFO") ->
    return null if @noLog
    for cb in @callbacks
      cb @makeLogLine txt, type

  makeLogLine: (txt, type="INFO") ->
    [@makeDateString(new Date), type, "#{@prefix}#{txt}"].join(@separator)

  makeDateString: (dateObj) ->
    @dateformat dateObj, "log"

  consoleCallback: (txt) ->
    console.log txt
