# out: ../lib/fileexistsSpec.js

tmp = require "tmp"
fileExists = require "./fileexists"

describe "fileexists", ->
  it "should return a error, when no input filepath is given", ->
    makeFileExists =  ->
      fileExists ""
    expect(makeFileExists).toThrowError()

  it "should return true if a file exists", ->
    tmpFileObj = tmp.fileSync()
    expect(fileExists tmpFileObj.name).toEqual(true)
    tmpFileObj.removeCallback()

  it "should return false if file not exists", ->
    expect(fileExists "noFile").toEqual(false)
