# out: ../lib/LogFactory.js

Log = require "./log"
Conf = require "./confFactory"
conf = Conf.makeConf()
settings = conf.load "settings"

module.exports.makeLog = ->
  log = new Log()
  if settings.debugModus
    log.debugModus = true
  log
