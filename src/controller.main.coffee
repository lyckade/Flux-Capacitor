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

vueBackupFiles = Vue.extend({
  template: '#backup-files-template'
  data: ->
    files: this.$root.active.backupCache
    active: this.$root.active
    activeIndex: this.$root.activeIndex
    fsstats: this.fileStats this.files
  methods:
    fileStats: (filelist) ->
      return [] if filelist is undefined or not filelist instanceof Array
      stats = []
      for f in filelist
        stats.push fse.fsstatSync(f)
      stats
  events:
    'active': ->
      this.files = this.$root.active.backupCache
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
Vue.component "files", vueBackupFiles


vm = new Vue({
  el: '#fluxcapacitor',
  data:
    active: dfc.selectedObject
    activeIndex: dfc.selectedObjectIndex
    folders: dfc.getObjects()
    t: t
    activeTab: 'files'
  events:
    'active': ->
      this.$broadcast 'active'
      this.active = dfc.selectedObject
      c.log.debug "active event in root"
  methods:
    'tabClick': (val) ->
      this.activeTab = val
      c.log.debug val
    startAutoCommit: ->
      dfc.startAutoCommit()
      this.folders = dfc.getObjects()
      dfc.write()
    stopAutoCommit: ->
      dfc.stopAutoCommit()
      this.folders = dfc.getObjects()
      dfc.write()
    commit: ->
      dfc.commit()
      this.folders = dfc.getObjects()
})
