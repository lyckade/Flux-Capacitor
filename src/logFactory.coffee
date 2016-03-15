# out: ../lib/LogFactory.js
fse = require "fs-extra"
Log = require "./log"
Conf = require "./confFactory"
conf = Conf.makeConf()
settings = conf.load "settings"

module.exports.makeLog = ->
  log = new Log()
  if settings.debugModus.value
    log.debugModus = true
  #Event driven logging for file output
  #List inside settings is defining the output types
  if settings.logFile.value isnt "" and settings.logFile.logModus.length > 0
    for m in settings.logFile.logModus
      log.addListener m, writeLog
  log

writeLog = (txt) ->
  fse.appendFile settings.logFile.value, "#{txt}\n", (err) ->
    throw err if err
