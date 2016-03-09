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

      it "should create a filename with timestamp", ->
        file1Stat = fse.statSync(file1.name)
        file1ts = ts.makeTimestamp file1Stat.mtime
        file1El = path.parse file1.name
        newFilename = "#{file1El.name}.#{file1ts}#{file1El.ext}"
        expect(df.makeFileName file1.name).toBe(newFilename)

  describe "skipFile", ->
    df = null
    beforeEach ->
      options =
        skipFile:
          patterns: [/skipMe/]
      df = new dataflux("src", "flux", options)
    it "should skip when the pattern matches", ->
      expect(df.skipFile "MyFolder/skipMe/file.txt").toBe(true)
  describe "Create Filepath", ->

  describe "Backup folder", ->
    it "should not watch the backup folder", ->

    it "should never use the backup folder as src", ->
