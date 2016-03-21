# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
Dataflux = require "../lib/dataflux"

path = require "path"
remote = require "remote"
dialog = remote.require "dialog"



conf.load "folders"
#log.addListener "a", (txt) ->

vueFolders = Vue.extend({
  template: 'T:<ul><li v-for="f in folders">{{f.src}}</li></ul>'
  data: ->
    folders: conf.folders
  })

Vue.component "folders", vueFolders

new Vue({
  el: '#fluxcapacitor',
  data: {
    folders: conf.folders
  }
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
