FolderSync = require "./foldersync"
path = require "path"

describe "FolderSync", ->

  describe "constructor", ->

    it "should include the default options of FileSync", ->
      expect(FolderSync.options.FileSync.justBackup).toEqual(false)

  describe "sync", ->

    it "should walk through the src folder", ->

    it "should sync each file of the src folder", ->

    it "should be able to skip files and folders", ->

  describe "makeDstPath", ->

    it "should create a destination path", ->
      srcFolder = path.join "MyFolder", "SourceFolder"
      dstFolder = path.join "Backup"
      filePath = path.join "MyFolder", "SourceFolder", "Subdir1", "Subdir2", "File"
      expect(FolderSync.makeDstPath(srcFolder, dstFolder, filePath))
      .toEqual(path.join dstFolder, "Subdir1", "Subdir2", "File")
