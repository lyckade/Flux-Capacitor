# out: ../lib/LogFactory.js
fse = require "fs-extra"
Log = require "./log"
Conf = require "./confFactory"
conf = Conf.makeConf()

module.exports.makeLog = ->
  log = new Log()
  if conf.settings.debugModus.value
    log.debugModus = true
  #Event driven logging for file output
  #List inside settings is defining the output types
  if conf.settings.logFile.value isnt "" and conf.settings.logFile.logModus.length > 0
    for m in conf.settings.logFile.logModus
      log.addListener m, writeLog
  log

writeLog = (txt) ->
  fse.appendFile conf.settings.logFile.value, "#{txt}\n", (err) ->
    throw err if err
