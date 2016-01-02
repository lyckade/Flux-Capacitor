fileCompare = require "./filecompare"
tmp = require "tmp"

describe "getNewerFile", ->
  tmpFileObj = null
  beforeAll ->
    tmpFileObj = tmp.fileSync()

  afterAll ->
    tmpFileObj.removeCallback()

  it "should throw an error, if firstFile does not exist", ->
    getNewerFileFunc = -> fileCompare.getNewerFile "noFile", tmpFileObj.name
    expect(getNewerFileFunc).toThrowError(/does not exist/)

  it "should throw an error, if secondFile does not exist", ->
    getNewerFileFunc = -> fileCompare.getNewerFile tmpFileObj.name, "noFile"
    expect(getNewerFileFunc).not.toThrowError()
