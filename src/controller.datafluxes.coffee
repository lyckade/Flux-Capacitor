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
      @objects.push(@loadObject index)
      if df.selected
        @selectedObjectIndex = index
        @selectedObject = df
    if @selectedObjectIndex is null
      @selectObject 0

  loadObject: (index) ->
    df = @conf.datafluxes[index]
    dataflux = new Dataflux(df.srcFolder, df.dataFluxFolder, df.options)
    dataflux.name = df.name
    dataflux.walk()
    dataflux.watch()
    if df.autoCommit
      dataflux.autoFlush()
    dataflux

  addDataflux: (srcFolder, fluxFolder) ->
    if srcFolder is undefined
      @log.error "No source folder is specified!"
      throw new Error "No src folder is specified"
    else if @checkFolder srcFolder
      if fluxFolder is undefined
        fluxFolder = @path.join srcFolder, @conf.settings.datafluxDefaultDir.value
      new_df = new Dataflux(srcFolder, fluxFolder)
      new_df.name = srcFolder
      new_df.walk()
      new_df.watch()
      @objects.push(new_df)

  checkFolder: (folderPath) ->
    for df in @objects
      if df.srcFolder is folderPath
        @log.error "#{folderPath} already added to the controller."
        return false
      else if @path.isSubfolder df.srcFolder, folderPath
        @log.error "#{folderPath} is a subfolder of an existing dataflux folder (#{df.srcFolder})."
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
      deactivated: df.deactivated

  selectObject: (index) ->
    @selectedObjectIndex = index
    @selectedObject = @getSelectedObject()


  reloadAllObjects: ->
    for o, index in @objects
      @reloadObject index

  reloadSelectedObject: ->
    @reloadObject @selectedObjectIndex

  reloadObject: (index) ->
    @conf.load "datafluxes"
    @objects[index].options = @conf.datafluxes[index].options
    oldCache = @objects[index].backupCache
    @objects[index].backupCache = []
    for f in oldCache
      @objects[index].addFileForBackup f
    if @objects[index].autoFlushActive
      @objects[index].stopAutoFlush()
      @objects[index].autoFlush()
    @objects[index].walk()


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
