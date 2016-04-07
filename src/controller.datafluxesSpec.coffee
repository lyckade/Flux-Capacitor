# out: ../lib/controller.datafluxesSpec.js
DatafluxesController = require "./controller.datafluxes"
path = require "./path-helper"
tmp = require "tmp"

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

    it "should create a fluxFolderPath, when no path is given", ->
      myDir = tmp.dirSync()
      dfc.conf.settings.datafluxDefaultDir.value = ".default"
      fluxFolderPath = path.join myDir.name, ".default"
      dfc.addDataflux myDir.name
      expect(dfc.objects[0].dataFluxFolder).toEqual(fluxFolderPath)


  describe "Check", ->
    xit "return false if folder already exists", ->
      dfc.addDataflux "MyFolder"
      expect(dfc.checkFolder "MyFolder").toBe(false)
      expect(dfc.checkFolder "AnotherFolder").toBe(true)

    xit "returns false if checked folder is subfolder of an existing dataflux folder", ->
      dfc.addDataflux "MyFolder"
      dfc.addDataflux "AnotherFolder"
      subFolder = path.join "MyFolder", "A", "B"
      expect(dfc.checkFolder subFolder).toBe(false)

    xit "returns false, when a dataflux folder is a subfolder of the folder", ->
      subFolder = path.join "MyFolder", "A", "B"
      dfc.addDataflux subFolder
      dfc.addDataflux "AnotherFolder"
      expect(dfc.checkFolder "MyFolder").toBe(false)

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
