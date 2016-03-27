# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
DatafluxesController = require "../lib/controller.datafluxes"
t = require "../lib/view.tFactory"

path = require "path"
remote = require "remote"
dialog = remote.require "dialog"



class MainController
  constructor: ->
    @log = logFactory.makeLog()
    @GUILogs = []
    @conf = Conf.makeConf()
    conf.load "settings"
    conf.load "folders"


  addLog: (txt) =>
    @GUILogs.unshift txt

  clearLog: =>
    @GUILogs = []

  getDataflux: (index) ->
    conf.folders[index]

  removeDataflux: (index) ->
    conf.folders.splice index, 1

#conf.load "folders"


dfc = new DatafluxesController()
dfc.loadObjects()
objects = dfc.getObjects()
selectedObject = dfc.getSelectedObject()

c = new MainController()

for mode in conf.settings.logGuiModus.value
  c.log.addListener mode, (txt) ->
    c.addLog "#{c.GUILogs.length+1}: #{txt}"

vueDatafluxes = Vue.extend({
  template: '#datafluxes-template'
  data: ->
    folders: objects
    active: selectedObject
    t: this.$root.t
  props: ['active']
  methods:
    addFolder: ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) =>
        f = files[0]
        dfc.addDataflux f
        dfc.write()
        @folders = dfc.getObjects()
    activateDataflux: (index) ->
      dfc.selectObject index
      this.active = dfc.getSelectedObject()
      this.$root.active = this.active
      this.folders = dfc.getObjects()
      c.log.debug "Activate: #{index}"
    remove: (index) ->
      c.log.debug "Remove: #{index}"
      dfc.removeDataflux index
      dfc.write()
      @folders = dfc.getObjects()
    startAutoCommit: (index) ->
      dfc.startAutoCommit index
      this.folders = dfc.getObjects()
      dfc.write()
    stopAutoCommit: (index) ->
      dfc.stopAutoCommit index
      this.folders = dfc.getObjects()
      dfc.write()
    commit: (index) ->
      dfc.commit index
      this.$root.active = this.active
      this.folders = dfc.getObjects()
  })

vueLogs = Vue.extend({
  template: '#logs-template'
  data: ->
    logs: c.GUILogs
    t: this.$root.t
  methods:
    clearLog: ->
      c.clearLog()
      this.logs = c.GUILogs
  })

vueSettings = Vue.extend({
  template: '#settings-template'
  data: ->
    active: this.$root.active
  })

Vue.component "datafluxes", vueDatafluxes
Vue.component "settings", vueSettings
Vue.component "logs", vueLogs

vm = new Vue({
  el: '#fluxcapacitor',
  data:
    active: dfc.getSelectedObject()
    t: t
})
