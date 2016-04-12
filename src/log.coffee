# out: ../lib/log.js

{EventEmitter} = require "events"
dateformat = require "dateformat"

module.exports =
class Log extends EventEmitter

  constructor: (options = {}) ->
    @separator = "|"
    @prefix = ""
    @noLog = false
    @debugModus = false
    @logTypes = [
      "ERROR"
      "WARNING"
      "NOTICE"
      "INFO"
      "DEBUG"
    ]

    @dateformat = dateformat
    @dateformat.masks.log = "yyyy.mm.dd HH:MM:ss"

    # callbacks are called via callback(txt)
    @callbacks = [@consoleCallback]

  error: (txt) ->
    @log txt, "ERROR"

  warning: (txt) ->
    @log txt, "WARNING"

  notice: (txt) ->
    @log txt, "NOTICE"

  info: (txt) ->
    @log txt, "INFO"

  debug: (txt) ->
    if @debugModus
      @log txt, "DEBUG"
    true

  log: (txt, type="INFO") ->
    return null if @noLog
    logLine = @makeLogLine txt, type
    for cb in @callbacks
      cb logLine
    @emit type, logLine

  makeLogLine: (txt, type="INFO") ->
    [@makeDateString(new Date), type, "#{@prefix}#{txt}"].join(@separator)

  makeDateString: (dateObj) ->
    @dateformat dateObj, "log"

  consoleCallback: (txt) ->
    console.log txt
