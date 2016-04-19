# out: ../lib/view.tFactory.js

CSON = require "season"
confFactory = require "./confFactory"

conf = confFactory.makeConf()


module.exports.load = load = ->
  conf.load "settings"
  locale = conf.settings.locale.value
  textFile = "./txt/#{locale}.cson"
  global.t = CSON.readFileSync textFile

load()
module.exports = global.t
