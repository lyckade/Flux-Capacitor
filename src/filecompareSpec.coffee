FileCompare = require "./filecompare"

tmp = require "tmp"

describe "getNewerFile", ->


  it "should call checkInputFiles to check the input parameters", ->
    spyOn FileCompare, "checkInputFiles"
    FileCompare.getNewerFile "firstFilename", "secondFileName"
    expect(FileCompare.checkInputFiles).toHaveBeenCalledWith(["firstFilename", "secondFileName"])

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
