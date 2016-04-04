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

c = new MainController()

for mode in conf.settings.logGuiModus.value
  c.log.addListener mode, (txt) ->
    c.addLog "#{c.GUILogs.length+1}| #{txt}"


vueSettings = Vue.extend({
  name: 'settings'
  template: '#settings-template'
  data: ->
    active: dfc.getSelectedObject()
    t: @$root.t
  methods:
    save: ->
      dfc.write()
      @$root.folders = dfc.getObjects()
    changeFolder: (type) ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) =>
        f = files[0]
        @active[type] = f
      c.log.debug type
  events:
    'refresh': ->
      c.log.debug "settings. active"
      @active = @$root.active
  })

vueLogs = Vue.extend({
  template: '#logs-template'
  data: ->
    logs: c.GUILogs
    t: @$root.t
  methods:
    clearLog: ->
      c.clearLog()
      @logs = c.GUILogs
  })

Vue.component "settings", vueSettings
Vue.component "logs", vueLogs
Vue.config.debug = true

vm = new Vue({
  el: '#fluxcapacitor',
  data:
    t: t
    folders: dfc.getObjects()
    active: dfc.getSelectedObject()
    activeIndex: dfc.selectedObjectIndex
    activeTab: 'files'
    objects: dfc.objects
    showLog: false
  events:
    'refreshRoot': ->
      c.log.debug "refreshRoot called"
      #@folders = dfc.getObjects()
      #@active = dfc.getSelectedObject()
      #@activeIndex = dfc.selectedObjectIndex
      #@objects = dfc.objects
  methods:
    'tabClick': (val) ->
      @activeTab = val
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
      @folders = dfc.getObjects()
      @active = dfc.getSelectedObject()
      @activeTab = 'files'
      @$broadcast 'refresh'
      dfc.write()

    startAutoCommit: (index=dfc.selectedObjectIndex) ->
      dfc.startAutoCommit(index)
      @folders = dfc.getObjects()
      @active = dfc.getSelectedObject()
      c.log.debug "#{@active.autoCommit}"
      dfc.write()

    stopAutoCommit: (index=dfc.selectedObjectIndex) ->
      dfc.stopAutoCommit(index)
      @folders = dfc.getObjects()
      @active = dfc.getSelectedObject()
      dfc.write()

    commit: (index=dfc.selectedObjectIndex) ->
      dfc.commit(index)
      @folders = dfc.getObjects()

    toggleLog: ->
      if @showLog
        @showLog = false
      else
        @showLog = true
})
