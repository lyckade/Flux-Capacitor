t = require "../lib/view.tFactory"
logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
conf.load "settings"

vm = new Vue({
  el: '#settings',
  data:
    t: t
    activeSection: 'dataflux'
    logTypes: log.logTypes
    selectedLogTypes: []
    settings: conf.settings
  methods:
    save: ->
      conf.write('settings')
      conf.refreshCallback()
  })
