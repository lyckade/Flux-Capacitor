# out: ../lib/LogFactory.js

Log = require "./log"

module.exports.makeLog = ->
  new Log()
