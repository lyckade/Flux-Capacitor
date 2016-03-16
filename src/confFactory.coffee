# out: ../lib/confFactory.js

module.exports.makeConf = ->
  # Singleton pattern over global var
  if global.conf is undefined
    Conf = require "./conf"
    global.conf = new Conf()
  global.conf
