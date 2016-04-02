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
    @selectedObjectIndex = null
    @selectedObject = null

  loadObjects: ->
    @conf.load "datafluxes"
    for df, index in @conf.datafluxes
      dataflux = new Dataflux(df.srcFolder, df.dataFluxFolder, df.options)
      dataflux.name = df.name
      dataflux.walk()
      dataflux.watch()
      if df.autoCommit
        dataflux.autoFlush()
      @objects.push dataflux
      if df.selected
        @selectedObjectIndex = index
        @selectedObject = df

  addDataflux: (srcFolder, fluxFolder) ->
    if srcFolder is undefined
      @log.error "No source folder is specified!"
      throw new Error "No src folder is specified"
    else if @checkFolder srcFolder
      if fluxFolder is undefined
        fluxFolder = @path.join srcFolder, @conf.settings.datafluxDefaultDir.value
      new_df = new Dataflux(srcFolder, fluxFolder)
      new_df.name = srcFolder
      @objects.push(new_df)

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

  removeDataflux: (index) ->
    @objects.splice index, 1

  write: ->
    @conf.datafluxes = @getObjects()
    @conf.write "datafluxes"

  getObjects: ->
    objs = []
    for df, index in @objects
      objs.push(@makeObjectProperties index)
    objs

  makeObjectProperties: (index) ->
    df = @objects[index]
    options =
      name: df.name
      srcFolder: df.srcFolder
      dataFluxFolder: df.dataFluxFolder
      options: df.options
      selected: index is @selectedObjectIndex
      autoCommit: df.autoFlushActive

  selectObject: (index) ->
    @selectedObjectIndex = index
    @selectedObject = @getSelectedObject()

  getSelectedObject: ->
    @getObject @selectedObjectIndex

  setSelectedObject: ->
    @objects[@selectedObjectIndex] = @selectedObject

  getObject: (index) ->
    @objects[index]

  commit: (index = @selectedObjectIndex) ->
    @objects[index].flushBackupCache()

  startAutoCommit: (index = @selectedObjectIndex) ->
    @objects[index].autoFlush()

  stopAutoCommit: (index = @selectedObjectIndex) ->
    @objects[index].stopAutoFlush()
