# out: ../lib/controller.datafluxesSpec.js
DatafluxesController = require "./controller.datafluxes"

describe "DatafluxesController", ->
  dfc = null
  beforeEach ->
    dfc = new DatafluxesController()
    dfc.log.noLog = true # disables logging for the tests

  describe "Add a new Dataflux", ->
    it "should return an error, when no srcFolder is given", ->
      add = ->
        dfc.addDataflux()
      expect(add).toThrowError(/No src folder is specified/)

    it "should use the default options for new datafluxes", ->

  describe "Check", ->
    it "returns false if checked folder is subfolder of an existing dataflux folder", ->

    it "returns false, when a dataflux folder is a subfolder of the folder", ->

  describe "Commiting changes to the dataflux folder", ->
    it "should be able to make auto commits", ->

    it "should be able to cancel the auto commits", ->

    it "should be able for manuall commits", ->

    it "should be able to return the status of the auto commit feature", ->

  describe "BackupCache", ->
    it "should be able to return the not commitet files from one dataflux", ->

    it "should be able to return the size for the cache of one dataflux", ->

    it "should be able to return all not commited files from all datafluxes", ->

  describe "Options", ->
    it "should be able to write the options of a dataflux", ->

    it "should be able to change the options of a dataflux", ->
