# out: ../lib/controller.main.js

logFactory = require "../lib/logFactory"
log = logFactory.makeLog()
Conf = require "../lib/confFactory"
conf = Conf.makeConf()

app = angular.module "flux-capacitor", ['ngMaterial']

app.controller "LogController", ($scope) ->
  $scope.logs = ["Test"]
  conf.addListener "loaded", ->
    for m in conf.settings.logGuiModus.value
      log.addListener m, (txt) ->
        $scope.logs.push txt
        $scope.$apply()
  conf.load "settings"
  $scope
