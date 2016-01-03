FolderSync = require "./foldersync"
path = require "path"
tmp = require "tmp"
fs = require "fs"

describe "FolderSync", ->

  describe "constructor", ->

    it "should include the default options of FileSync", ->
      expect(FolderSync.options.FileSync.justBackup).toEqual(false)

  describe "sync", ->

    it "should walk through the src folder", ->

    it "should sync each file of the src folder", ->

    it "should be able to skip files and folders", ->

  describe "skipItem", ->
    options = null
    beforeEach ->
      options =
        patterns: [/node_modules/, /.git/]

    it "should return true, when a item is a directory", ->
      tmpDirObj = tmp.dirSync()
      tmpItem = fs.statSync(tmpDirObj.name)
      expect(FolderSync.skipItem tmpItem, options).toEqual(true)
      tmpDirObj.removeCallback()

    it "should return true, when a pattern matches an item", ->
      tmpFileObj = tmp.fileSync({prefix: ".git"})
      tmpItem = fs.statSync(tmpFileObj.name)
      tmpItem.path = tmpFileObj.name
      expect(FolderSync.skipItem tmpItem, options).toEqual(true)
      tmpFileObj.removeCallback()

    it "should return false, when a pattern not matches", ->
      tmpFileObj = tmp.fileSync()
      tmpItem = fs.statSync(tmpFileObj.name)
      tmpItem.path = tmpFileObj.name
      expect(FolderSync.skipItem tmpItem, options).toEqual(false)
      tmpFileObj.removeCallback()

  describe "makeDstPath", ->

    it "should create a destination path", ->
      srcFolder = path.join "MyFolder", "SourceFolder"
      dstFolder = path.join "Backup"
      filePath = path.join "MyFolder", "SourceFolder", "Subdir1", "Subdir2", "File"
      expect(FolderSync.makeDstPath(srcFolder, dstFolder, filePath))
      .toEqual(path.join dstFolder, "Subdir1", "Subdir2", "File")
