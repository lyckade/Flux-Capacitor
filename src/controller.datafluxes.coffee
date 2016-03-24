# out: ../lib/controller.datafluxes.js
dataflux = require "./dataflux"
log = require "./logFactory"
conf = require "./confFactory"


module.exports =
class DatafluxesController
  constructor: ->
    @dfluxes = []
    @log = log.makeLog()
    @conf = conf.makeConf()

  addDataflux: (srcFolder, fluxFolder="") ->
    if srcFolder is undefined
      @log.error "No source folder is specified!"
      throw new Error "No src folder is specified"
