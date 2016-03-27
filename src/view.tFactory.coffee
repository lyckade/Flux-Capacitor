# out: ../lib/view.tFactory.js

CSON = require "season"
confFactory = require "./confFactory"

conf = confFactory.makeConf()
conf.load "settings"
locale = conf.settings.defaultLocale.value

textFile = "./txt/#{locale}.cson"

module.exports = CSON.readFileSync textFile
