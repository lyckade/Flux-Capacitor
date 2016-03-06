# out: ../lib/foldersyncSpec.js

foldersync = require "./foldersync"
path = require "path"
tmp = require "tmp"
fs = require "fs-extra"
events = require "events"
eventEmitter = new events.EventEmitter()


describe "FolderSync", ->

  describe "constructor", ->
    it "should include the default options of FileSync", ->
      FolderSync = new foldersync
      expect(FolderSync.options.FileSync.justBackup).toEqual(false)

  describe "sync", ->
    it "should call @syncItem, when walk gives a callback", ->
      FolderSync = new foldersync
      spyOn(FolderSync, "syncItem")
      spyOn(FolderSync, "walk").and.callFake (folder, callback) ->
        callback "myFirstItem"
      FolderSync.sync "myFolder", "backup"
      expect(FolderSync.syncItem).toHaveBeenCalledWith("myFirstItem")

  describe "skipItem", ->
    options = null
    beforeEach ->
      options =
        patterns: [/node_modules/, /.git/]

    it "should return true, when a item is a directory", ->
      FolderSync = new foldersync
      tmpDirObj = tmp.dirSync()
      tmpItem = fs.statSync(tmpDirObj.name)
      tmpItem.path = "tmpPath"
      expect(FolderSync.skipItem tmpItem, options).toEqual(true)
      tmpDirObj.removeCallback()

    it "should return true, when a pattern matches an item", ->
      FolderSync = new foldersync
      tmpFileObj = tmp.fileSync({prefix: ".git"})
      tmpItem = fs.statSync(tmpFileObj.name)
      tmpItem.path = tmpFileObj.name
      expect(FolderSync.skipItem tmpItem, options).toEqual(true)
      tmpFileObj.removeCallback()

    it "should return false, when a pattern not matches", ->
      FolderSync = new foldersync
      tmpFileObj = tmp.fileSync()
      tmpItem = fs.statSync(tmpFileObj.name)
      tmpItem.path = tmpFileObj.name
      expect(FolderSync.skipItem tmpItem, options).toEqual(false)
      tmpFileObj.removeCallback()

  describe "makeDstPath", ->

    it "should create a destination path", ->
      FolderSync = new foldersync
      srcFolder = path.join "MyFolder", "SourceFolder"
      dstFolder = path.join "Backup"
      filePath = path.join "MyFolder", "SourceFolder", "Subdir1", "Subdir2", "File"
      FolderSync.srcFolder = srcFolder
      FolderSync.dstFolder = dstFolder
      expect(FolderSync.makeDstPath(filePath))
      .toEqual(path.join dstFolder, "Subdir1", "Subdir2", "File")
