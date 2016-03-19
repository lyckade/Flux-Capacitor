# out: ../lib/datafluxSpec.js

fse = require "fs-extra"
tmp = require "tmp"
path = require "./path-helper"
ts = require "./timestamp"

dataflux = require "./dataflux"

describe "Dataflux", ->

  describe "Create Flux Filename", ->
    describe "file tests", ->
      file1 = null
      df = null
      beforeEach ->
        file1 = tmp.fileSync()
        df = new dataflux()
      afterEach ->
        file1.removeCallback()

      it "should add the timestamp to the filepath", ->
        file1Stat = fse.statSync(file1.name)
        file1ts = ts.makeTimestamp file1Stat.mtime
        file1El = path.parse file1.name
        newFilename = path.join file1El.dir, "#{file1El.name}.#{file1ts}#{file1El.ext}"
        expect(df.addTimestamp file1.name).toBe(newFilename)

  describe "skipFile", ->
    describe "file actions", ->
      df = null
      beforeEach ->
        options =
          skipFile:
            patterns: [/skipMe/, /meToo/]
        df = new dataflux("src", "flux", options)
        spyOn(df, "isDirectory").and.returnValue(false)
      it "should return true when the pattern matches", ->
        expect(df.skipFile "MyFolder/skipMe/file.txt").toBe(true)
        expect(df.skipFile "MyFolder/meToo/file.txt").toBe(true)
      it "should return false when the pattern not matches", ->
        expect(df.skipFile "MyFolder/doNotSkip/file.txt").toBe(false)
    describe "directories", ->
      it "should not add directories", ->
        myDir = tmp.dirSync()
        df = new dataflux()
        expect(df.skipFile myDir.name).toBe(true)
        myDir.removeCallback()

    describe "flux files", ->
      it "should check if a file is from the flux folder", ->
        myDir = tmp.dirSync()
        fluxFolder = path.join myDir.name, "flux"
        fluxFile = path.join fluxFolder, "fluxFile.txt"
        noFluxFile = path.join myDir.name, "myFolder", "myFile.txt"
        df = new dataflux(myDir.name, fluxFolder)
        expect(df.isFluxFile fluxFile).toBe(true)
        expect(df.isFluxFile noFluxFile).toBe(false)
        myDir.removeCallback()

      it "should throw an error, when a fluxFolder file should be copied", ->
        myDir = tmp.dirSync()
        fluxFolder = path.join myDir.name, "flux"
        fluxFile = path.join fluxFolder, "fluxFile.txt"
        df = new dataflux(myDir.name, fluxFolder)
        copyFile = ->
          df.copyFileVersion fluxFile
        expect(copyFile).toThrowError(/is part of the FluxFolder/)
        myDir.removeCallback()

  describe "flushBackupCache", ->
    it "should copy the files in the cache and empty it afterwards", ->
      df = new dataflux("src", "flux")
      df.log.noLog = true
      df.copyFileVersion = jasmine.createSpy("copyFileVersion")
      df.backupCache = ["file1", "file2"]
      expect(df.backupCache.length).toBe(2)
      df.flushBackupCache()
      expect(df.backupCache.length).toBe(0)
      expect(df.copyFileVersion.calls.allArgs()).toEqual([['file1'], ['file2']])

  describe "copyFileVersion", ->
    it "should copy the file into the fluxFolder", ->
      srcFolder = path.join "myFolder"
      myFile = path.join "myFolder", "Sub1", "Sub2", "file.txt"
      fluxFolder = path.join "flux"
      fluxFile = path.join "flux", "Sub1", "Sub2", "file.txt"
      df = new dataflux srcFolder, fluxFolder
      df.log.noLog = true
      df.fse = jasmine.createSpyObj "fse", ["copySync"]
      df.fileExists = -> return true
      df.addTimestamp = (filePath) -> filePath
      df.copyFileVersion myFile
      expect(df.fse.copySync).toHaveBeenCalledWith(myFile, fluxFile)
