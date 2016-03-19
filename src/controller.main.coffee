# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()
Dataflux = require "../lib/dataflux"

app = angular.module "flux-capacitor", ['ngMaterial']

path = require "path"
remote = require "remote"
dialog = remote.require "dialog"

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
    log.notice "addDataflux"
    dialog.showOpenDialog {properties: ['openDirectory', 'createDirectory']}, (files) ->
      f = files[0]
      $scope.folders.push {src: f, flux: path.join f, "flux"}
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
        console.log $scope
        #$scope.$apply()
  conf.load "settings"
  $scope

datafluxes = {}
conf.load "folders"
for f in conf.folders
  datafluxes[f.src] = new Dataflux f.src, f.flux
  datafluxes[f.src].watch()
  #datafluxes[f.src].autoFlush()
#df.watch()
#df.autoFlush()
