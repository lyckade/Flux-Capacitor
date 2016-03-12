# out: ../lib/LogFactory.js

Log = require "./log"

module.exports.makeLog = ->
  log = new Log()
  log.debugModus = true
  log
