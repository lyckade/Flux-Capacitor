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
    @selectedObject = null

  loadObjects: ->
    @conf.load "datafluxes"
    for df, index in @conf.datafluxes
      @objects.push(new Dataflux(df.srcFolder, df.dataFluxFolder, df.options))
      if df.selected
        @selectedObject = index

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

  write: ->
    @conf.datafluxes = @getObjects()
    @conf.write "datafluxes"

  getObjects: ->
    objs = []
    for df, index in @objects
      dfOptions =
        srcFolder: df.srcFolder
        dataFluxFolder: df.dataFluxFolder
        options: df.options
        selected: index is @selectedObject
      objs.push dfOptions
    objs

  selectObject: (index) ->
    @selectedObject = index

  getSelectedObject: ->
    @getObject @selectedObject

  getObject: (index) ->
    @objects[index]
