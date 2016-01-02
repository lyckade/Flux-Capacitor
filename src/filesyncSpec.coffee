tmp = require "tmp"
fileSync = require "./filesync"
describe "Filesync", ->
  fileObj = null

  beforeAll ->
    fileObj = tmp.fileSync()

  afterAll ->
    fileObj.removeCallback()

  it "should throw an Error, if source file does not exists", ->
    makeFileSync = ->
      fileSync "noFile", fileObj.name
    expect(makeFileSync).toThrowError(/file does not exist/)

  it "should throw an Error, if destination is empty", ->
    makeFileSync = ->
      fileSync fileObj.name
    expect(makeFileSync).toThrowError("No destination file is given!")
