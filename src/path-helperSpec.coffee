# out: ../lib/path-helperSpec.js

ph = require "./path-helper"
path = require "path"
describe "makePath", ->

  it "should create a destination path", ->
    srcFolder = path.join "MyFolder", "SourceFolder"
    dstFolder = path.join "Backup"
    filePath = path.join "MyFolder", "SourceFolder", "Subdir1", "Subdir2", "File"
    expect(ph.makePath(srcFolder, dstFolder, filePath))
    .toEqual(path.join dstFolder, "Subdir1", "Subdir2", "File")
