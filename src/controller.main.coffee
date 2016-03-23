# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
Dataflux = require "../lib/dataflux"

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
    @activeDataflux = @getDataflux 0

  addLog: (txt) =>
    @GUILogs.unshift txt

  clearLog: =>
    @GUILogs = []

  getDataflux: (index) ->
    conf.folders[index]

#conf.load "folders"
c = new MainController()

for mode in conf.settings.logGuiModus.value
  c.log.addListener mode, (txt) ->
    c.addLog "#{c.GUILogs.length+1}: #{txt}"



vueDatafluxes = Vue.extend({
  template: '#datafluxes-template'
  data: ->
    folders: c.conf.folders
    active: c.activeDataflux
  methods:
    addFolder: ->
      dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) ->
        f = files[0]
        c.conf.folders.push {src: f, flux: path.join f, conf.settings.fluxDefaultDir.value}
        c.conf.write "folders"
    activateDataflux: (index) ->
      c.activeDataflux = c.getDataflux index
      this.active = c.activeDataflux
      c.log.debug "Activate: #{index}"
  })

vueLogs = Vue.extend({
  template: '#logs-template'
  data: ->
    logs: c.GUILogs
  methods:
    clearLog: ->
      c.clearLog()
      this.logs = c.GUILogs
  })

Vue.component "datafluxes", vueDatafluxes
Vue.component "logs", vueLogs

vm = new Vue({
  el: '#fluxcapacitor',
})


###
app.config ($mdThemingProvider) ->
  $mdThemingProvider.theme('default')
  .primaryPalette('light-green')
  .accentPalette('lime')
  .warnPalette('blue-grey')

app.controller "DatafluxController", ($scope) ->
  conf.addListener "loaded", ->
    $scope.folders = conf.folders
    #$scope.$apply()
  $scope.addDataflux = ->
    dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) ->
      f = files[0]
      $scope.folders.push {src: f, flux: path.join f, conf.settings.fluxDefaultDir.value}
      conf.folders = $scope.folders
      conf.write("folders", conf.removeHashKeyFromArray conf.folders)
      $scope.$apply()
  $scope

app.controller "LogController", ($scope) ->
  $scope.logs = []
  conf.addListener "loaded", ->
    for m in conf.settings.logGuiModus.value
      log.addListener m, (txt) ->
        $scope.logs.unshift "#{$scope.logs.length}:#{txt}"
        $scope.$apply()
  conf.load "settings"
  $scope

datafluxes = {}
conf.load "folders"
for f in conf.folders
  datafluxes[f.src] = new Dataflux f.src, f.flux
  datafluxes[f.src].walk()
  datafluxes[f.src].watch()
  datafluxes[f.src].autoFlush()
#df.watch()
#df.autoFlush()
###
