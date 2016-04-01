# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
DatafluxesController = require "../lib/controller.datafluxes"
t = require "../lib/view.tFactory"

fse = require "fs-extra"
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

  fileStats: (filelist) ->
    return [] if filelist is undefined or not filelist instanceof Array
    stats = []
    for f in filelist
      stats.push fse.fsstatSync(f)
    stats


dfc = new DatafluxesController()
dfc.loadObjects()
#objects = dfc.getObjects()
#selectedObject = dfc.getSelectedObject()

c = new MainController()

for mode in conf.settings.logGuiModus.value
  c.log.addListener mode, (txt) ->
    c.addLog "#{c.GUILogs.length+1}| #{txt}"

vueSettings = Vue.extend({
  name: 'settings'
  template: '#settings-template'
  data: ->
    #active: this.$parent.active
    active: dfc.getSelectedObject()
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


Vue.component "settings", vueSettings
Vue.component "logs", vueLogs


vm = new Vue({
  el: '#fluxcapacitor',
  data:
    t: t
    folders: dfc.getObjects()
    active: dfc.getSelectedObject
    activeIndex: dfc.selectedObjectIndex
    activeTab: 'files'
  events:
    'active': ->
      this.$broadcast 'active'
      this.active = dfc.getSelectedObject
      c.log.debug "active event in root"
    'refreshRoot': ->
      @folders = dfc.getObjects()
      @active = dfc.getSelectedObject
      @activeIndex = dfc.selectedObjectIndex
  methods:
    'tabClick': (val) ->
      this.activeTab = val
      c.log.debug val
    addFolder: ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) =>
        f = files[0]
        dfc.addDataflux f
        dfc.write()
        @folders = dfc.getObjects()
    removeFolder: (index) ->
      c.log.debug "Remove: #{index}"
      dfc.removeDataflux index
      @folders = dfc.getObjects()
      dfc.write()
    activateDataflux: (index) ->
      dfc.selectObject index
      this.folders = dfc.getObjects()
      this.active = dfc.getSelectedObject()
      this.$on 'refreshRoot'
      dfc.write()
      c.log.debug "Activate: #{index}"
    startAutoCommit: ->
      dfc.startAutoCommit()
      this.folders = dfc.getObjects()
      this.active = dfc.selectObject this.activeIndex
      dfc.write()
    stopAutoCommit: ->
      dfc.stopAutoCommit()
      this.folders = dfc.getObjects()
      this.active = dfc.selectObject this.activeIndex
      dfc.write()
    commit: ->
      dfc.commit()
      this.folders = dfc.getObjects()
})
