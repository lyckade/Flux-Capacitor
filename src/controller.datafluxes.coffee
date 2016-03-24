# out: ../lib/controller.datafluxes.js
Dataflux = require "./dataflux"
log = require "./logFactory"
conf = require "./confFactory"
path = require "./path-helper"


module.exports =
class DatafluxesController
  constructor: ->
    @objects = []
    @path = path
    @log = log.makeLog()
    @conf = conf.makeConf()
    @conf.load "settings"
    @conf.load "datafluxes"

  addDataflux: (srcFolder, fluxFolder) ->
    if srcFolder is undefined
      @log.error "No source folder is specified!"
      throw new Error "No src folder is specified"
    else if @checkFolder srcFolder
      if fluxFolder is undefined
        fluxFolder = @path.join srcFolder, @conf.settings.datafluxDefaultDir.value
      @objects.push(new Dataflux(srcFolder, fluxFolder))

  checkFolder: (folderPath) ->
    for df in @objects
      if df.srcFolder is folderPath
        @log.error "#{folderPath} already added to the controller."
        return false
      else if @path.isSubfolder df.srcFolder, folderPath
        @log.error "#{folderPath} is a subfolder of an existing dataflux folder."
        return false
      else if @path.isSubfolder folderPath, df.srcFolder
        @log.error "The subfolder #{df.srcFolder} is already a dataflux!"
        return false
    return true
