FileCompare = require "./filecompare"

tmp = require "tmp"

describe "getNewerFile and getOlderFile", ->

  it "should call checkInputFiles to check the input parameters", ->
    spyOn FileCompare, "checkInputFiles"
    spyOn FileCompare, "getLastModifiedTime"
    FileCompare.getNewerFile "firstFilename", "secondFileName"
    expect(FileCompare.checkInputFiles).toHaveBeenCalledWith(["firstFilename", "secondFileName"])

  describe "time relevant", ->
    newerTime = null
    olderTime = null
    beforeAll ->
      newerTime = new Date(2015, 1, 1, 11, 55, 0)
      olderTime = new Date(2014, 2, 1, 11, 55, 0)
      spyOn(FileCompare, "checkInputFiles").and.returnValue(true)
      spyOn(FileCompare, "getLastModifiedTime").and.returnValues(newerTime, olderTime)
    describe "getNewerFile", ->
      it "should return the newer file - with the bigger timestamp", ->
        expect(FileCompare.getNewerFile "newerFile", "olderFile").toEqual("newerFile")

    describe "getOlderFile", ->
      it "should return the older file", ->
        expect(FileCompare.getOlderFile "newerFile", "olderFile").toEqual("olderFile")

describe "checkInputFiles", ->
  tmpFileObj = null

  beforeAll ->
    tmpFileObj = tmp.fileSync()

  afterAll ->
    tmpFileObj.removeCallback()

  it "should throw an error, if a file does not exist", ->
    checkInputFilesFunc = -> FileCompare.checkInputFiles ["noFile", tmpFileObj.name]
    expect(checkInputFilesFunc).toThrowError(/does not exist/)

  it "should throw an error, if secondFile does not exist", ->
    checkInputFilesFunc = -> FileCompare.checkInputFiles [tmpFileObj.name, "noFile"]
    expect(checkInputFilesFunc).toThrowError()

  it "should not throw an error, if files exist", ->
    checkInputFilesFunc = -> FileCompare.checkInputFiles [tmpFileObj.name, tmpFileObj.name]
    expect(checkInputFilesFunc).not.toThrowError()

  it "should throw an error, if a file path is empty", ->
    checkInputFilesFunc = -> FileCompare.checkInputFiles [tmpFileObj.name, ""]
    expect(checkInputFilesFunc).toThrowError()
