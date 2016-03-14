# out: ../lib/confFactory.js

Conf = require "./conf"

module.exports.makeConf = ->
  new Conf()
