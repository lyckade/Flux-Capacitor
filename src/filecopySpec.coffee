FileCopy = require "./filecopy.js"
tmp = require "tmp"
path = require "path"

describe "FileCopy Module", ->
  tmpFolderObj = null
  fileDoesNotExist = null

  beforeAll ->


  afterAll ->


  describe "Constructor", ->
    it "should throw an error, when the source file not exists", ->
      tmpFolderObj = tmp.dirSync {unsafeCleanup: true}
      fileDoesNottExist = path.join tmpFolderObj.name, "noFile"
      makeFCopy = ->
        fcopyInstance = new FileCopy fileDoesNotExist, fileDoesNotExist
      expect(makeFCopy).toThrowError /file does not exist!/
      tmpFolderObj.removeCallback()
    it "should not throw an error, when source file exists", ->
      tmpFileObj1 = tmp.fileSync()
      tmpFileObj2 = tmp.fileSync()
      makeFCopy = ->
        fcopyInstance = new FileCopy tmpFileObj1.name, tmpFileObj2.name
      expect(makeFCopy).not.toThrowError()
      tmpFileObj1.removeCallback()
      tmpFileObj2.removeCallback()
    it "should trhow an error, when no destination is given", ->
      tmpFileObj1 = tmp.fileSync()
      makeFCopy = ->
        fcopyInstance = new FileCopy tmpFileObj1.name, ""
      expect(makeFCopy).toThrowError "No destination file given!"
      tmpFileObj1.removeCallback()
