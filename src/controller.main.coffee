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
    log = txt.split "|"
    @GUILogs.unshift log

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
    c.addLog "#{c.GUILogs.length+1}| #{txt}"

vueSettings = Vue.extend({
  name: 'settings'
  template: '#settings-template'
  data: ->
    #active: this.$parent.active
    active: dfc.selectedObject
    t: this.$root.t
  methods:
    save: ->
      dfc.setSelectedObject()
      dfc.write()
    changeFolder: (type) ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) =>
        f = files[0]
        @active[type] = f
      c.log.debug type
  events:
    'active': ->
      c.log.debug "settings. active"
      this.active = this.$parent.active

  })

vueDatafluxes = Vue.extend({
  template: '#datafluxes-template'
  data: ->
    folders: objects
    active: dfc.selectedObject
    t: this.$root.t
  methods:
    addFolder: ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) =>
        f = files[0]
        dfc.addDataflux f
        dfc.write()
        @folders = dfc.getObjects()
    activateDataflux: (index) ->
      dfc.selectObject index
      this.active = dfc.selectedObject
      this.$root.active = this.active
      this.$dispatch 'active'
      this.folders = dfc.getObjects()
      c.log.debug "Activate: #{index}"
    remove: (index) ->
      c.log.debug "Remove: #{index}"
      dfc.removeDataflux index
      dfc.write()
      @folders = dfc.getObjects()

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


Vue.component "datafluxes", vueDatafluxes
Vue.component "settings", vueSettings
Vue.component "logs", vueLogs


vm = new Vue({
  el: '#fluxcapacitor',
  data:
    active: dfc.selectedObject
    folders: dfc.getObjects()
    t: t
    activeTab: 'files'
  events:
    'active': ->
      this.$broadcast 'active'
      this.active = dfc.selectedObject
  methods:
    'tabClick': (val) ->
      this.activeTab = val
      c.log.debug val
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
      this.folders = dfc.getObjects()
})
