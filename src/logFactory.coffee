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
  if settings.logFile.value isnt ""
    log.callbacks.push (txt) ->
      fse.appendFile settings.logFile.value, "#{txt}\n", (err) ->
        throw err if err
  log
