# out: ../lib/filesyncSpec.js

tmp = require "tmp"
FileSync = require "./filesync"
fileSync = new FileSync
FileCompare = require "./filecompare"

describe "Filesync", ->
  fileObj = null

  beforeAll ->
    fileObj = tmp.fileSync()

  afterAll ->
    fileObj.removeCallback()

  it "should throw an Error, if source file does not exists", ->
    makeFileSync = ->
      fileSync.sync "noFile", fileObj.name
    expect(makeFileSync).toThrowError(/file does not exist/)

  it "should throw an Error, if destination is empty", ->
    makeFileSync = ->
      fileSync.sync fileObj.name
    expect(makeFileSync).toThrowError("No destination file is given!")

  describe "with the default options", ->
    it "should copy the newer to the older file", ->
      spyOn(FileCompare, "getNewerFile").and.returnValue("newerFile")
      spyOn(FileCompare, "getOlderFile").and.returnValue("olderFile")
      spyOn(fileSync, "fileExists").and.returnValue(true)
      spyOn fileSync, "copy"
      fileSync.sync "olderFile", "newerFile", {noErrors: true}
      expect(fileSync.copy).toHaveBeenCalledWith("newerFile", "olderFile")

    it "should copy the files if destination file not exists", ->
      spyOn fileSync, "copy"
      fileSync.sync fileObj.name, "notExistingFile"
      expect(fileSync.copy).toHaveBeenCalledWith(fileObj.name, "notExistingFile")

  describe "doNotCopy", ->
    it "should not copy, when srcFile is dstFile", ->
      doNotCopy = ->
        fileSync.doNotCopy fileObj.name, fileObj.name
      expect(doNotCopy).toThrowError(/Source and destination are same file/)
      fileSync.syncOptions.noErrors = true
      expect(fileSync.doNotCopy fileObj.name, fileObj.name).toBe(true)

  describe "doNotCopy justNewFiles", ->

    beforeAll ->
      fileSync.syncOptions.justNewFiles = true

    it "should return true, when justNewFiles and dstFile exists", ->
      fileObj2 = tmp.fileSync()
      expect(fileSync.doNotCopy fileObj.name, fileObj2.name).toBe(true)
      fileObj2.removeCallback()

    it "should copy return false, when justNewFiles and dstFile not exists", ->
      expect(fileSync.doNotCopy fileObj.name, "newFile").toBe(false)

  describe "with the just Backup option", ->
    it "should copy src to dst file", ->
      firstFile = tmp.fileSync()
      secondFile = tmp.fileSync()
      spyOn fileSync, "copy"
      fileSync.sync firstFile.name, secondFile.name, {justBackup: true}
      expect(fileSync.copy).toHaveBeenCalledWith(firstFile.name, secondFile.name)
      firstFile.removeCallback()
      secondFile.removeCallback()
