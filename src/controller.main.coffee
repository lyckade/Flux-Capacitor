# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
DatafluxesController = require "../lib/controller.datafluxes"
timestamp = require "../lib/timestamp"
bytesFormat = require "../lib/bytesFormat"
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
    @settingsWindow = null
    @aboutWindow = null


  addLog: (txt) =>
    log = txt.split "|"
    @GUILogs.unshift log

  clearLog: =>
    @GUILogs = []

  loadConf: ->
    conf.load "settings"
    conf.load "folders"

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

  openSettings: ->
    # Singleton for the settings window
    return if @settingsWindow isnt null
    @settingsWindow = @openWindow()
    @settingsWindow.loadURL("file://#{__dirname}/../views/settings.html")
    @settingsWindow.on 'closed', =>
      @settingsWindow = null
      @loadConf()
    #settingsWindow.
  openAbout: ->
    return if @aboutWindow isnt null
    @aboutWindow = @openWindow()
    @aboutWindow.loadURL("file://#{__dirname}/../views/about.html")
    @aboutWindow.on 'closed', =>
      @aboutWindow = null
  openWindow: ->
    BrowserWindow = require('electron').remote.BrowserWindow
    win = new BrowserWindow(
      {
        width: 800
        height: 600
        alwaysOnTop: true
        skipTaskbar: true
        minimizable: false
        maximizable: false
      })


dfc = new DatafluxesController()
dfc.loadObjects()

c = new MainController()

conf.addListener "loaded", ->
  c.log.debug "conf loaded fired"
  c.log.removeAllListeners()
  for mode in conf.settings.logGuiModus.value
    c.log.addListener mode, (txt) ->
      c.addLog "#{c.GUILogs.length+1}| #{txt}"

c.loadConf()


vueSettings = Vue.extend({
  name: 'settings'
  template: '#settings-template'
  data: ->
    active: dfc.getSelectedObject()
    t: @$root.t
  methods:
    save: ->
      dfc.write()
      @$dispatch 'refreshActive'

    addPattern: ->
      @active.options.skipFile.patterns.push ""
    removePattern: (index) ->
      @active.options.skipFile.patterns.splice index, 1
  events:
    'refresh': ->
      c.log.debug "settings. active"
      @active = @$root.active
  })

vueLogs = Vue.extend({
  template: '#logs-template'
  data: ->
    logs: @$root.logs
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
    logs: c.GUILogs
    folders: dfc.getObjects()
    active: dfc.getSelectedObject()
    activeIndex: dfc.selectedObjectIndex
    activeTab: 'files'
    objects: dfc.objects
    showLog: false

  computed:
    filesToCommit: ->
      files = []
      for f in @active.backupCache
        fstat = fse.statSync f
        fstat.lastChange = timestamp.makeDate fstat.mtime
        fstat.size = bytesFormat fstat.size
        fstat.path = f
        files.push fstat
      files

  events:
    'refreshAll': =>
      @folders = dfc.getObjects()
      dfc.reloadAllObjects()
      #@objects = dfc.objects
      @active = dfc.getSelectedObject()
      @activeIndex = dfc.selectedObjectIndex
    'refreshActive': ->
      dfc.reloadSelectedObject()


  methods:
    refreshRoot: ->
      @$emit 'refreshAll'
    tabClick: (val) ->
      @activeTab = val
      c.log.debug val
    addFolder: ->
      c.log.debug "AddFolder called"
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) ->
        return if files is undefined
        f = files[0]
        dfc.addDataflux f
        dfc.write()
        #@folders = dfc.getObjects()
    removeFolder: (index) ->
      if index is @activeIndex
        @activeIndex = 0
        @activateDataflux 0
      if confirm t.txt.confirmDelete
        c.log.debug "Remove: #{index} - Active: #{@activeIndex}"
        if index is @activeIndex
          @activeIndex = 0
          c.log.debug "removeFolder: activate 0"
        dfc.removeDataflux index
        @objects = dfc.objects
        # objects needs to update before folders!
        # because the loop goes over folders
        #@folders = dfc.getObjects()
        @active = dfc.getSelectedObject()
        dfc.write()
      else
        @activateDataflux index
    activateDataflux: (index) ->
      c.log.debug "activate #{index}"
      dfc.selectObject index
      @folders = dfc.getObjects()
      @objects = dfc.objects
      @active = dfc.getSelectedObject()
      @activeIndex = index
      @$broadcast 'refresh'
      @activeTab = 'files'
      dfc.write()

    startAutoCommit: (index=dfc.selectedObjectIndex) ->
      dfc.startAutoCommit(index)
      #@folders = dfc.getObjects()
      @active = dfc.getSelectedObject()
      dfc.write()

    stopAutoCommit: (index=dfc.selectedObjectIndex) ->
      dfc.stopAutoCommit(index)
      #@folders = dfc.getObjects()
      @active = dfc.getSelectedObject()
      dfc.write()

    commit: (index=dfc.selectedObjectIndex) ->
      dfc.commit(index)
      #@folders = dfc.getObjects()

    commitAll: ->
      for obj in dfc.objects
        obj.flushBackupCache()

    toggleLog: ->
      if @showLog
        @showLog = false
      else
        @showLog = true
    openSettings: ->
      c.openSettings()
})

ipcRenderer = require('electron').ipcRenderer
Menu = remote.Menu
template = require('../lib/menu')
menu = Menu.buildFromTemplate(template)
Menu.setApplicationMenu(menu)
ipcRenderer.on 'addFolder', ->
  vm.addFolder()
ipcRenderer.on 'reloadFolders', ->
  vm.refreshRoot()
ipcRenderer.on 'commitAll', ->
  vm.commitAll()
ipcRenderer.on 'openSettings', ->
  c.openSettings()
ipcRenderer.on 'openAbout', ->
  c.openAbout()
