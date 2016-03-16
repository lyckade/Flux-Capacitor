# out: ../lib/LogFactory.js
fse = require "fs-extra"
Log = require "./log"
Conf = require "./confFactory"
conf = Conf.makeConf()
conf.load "settings"

module.exports.makeLog = ->
  # Singleton for log instance
  if global.log is undefined
    global.log = new Log()
    refreshSettings()
  conf.addListener "loaded", ->
    refreshSettings()
  global.log

refreshSettings = ->
  if conf.settings.debugModus.value
    global.log.debugModus = true
  #Event driven logging for file output
  #List inside settings is defining the output types
  global.log.removeAllListeners()
  if conf.settings.logFile.value isnt "" and conf.settings.logFile.logModus.length > 0
    for m in conf.settings.logFile.logModus
      global.log.addListener m, writeLog
  global.log.debug "Log settings loaded"

writeLog = (txt) ->
  fse.appendFile conf.settings.logFile.value, "#{txt}\n", (err) ->
    throw err if err
