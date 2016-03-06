# out: ../lib/path-helperSpec.js

ph = require "./path-helper"
path = require "path"
describe "makeDstPath", ->

  it "should create a destination path", ->
    PathHelper = new ph
    srcFolder = path.join "MyFolder", "SourceFolder"
    dstFolder = path.join "Backup"
    filePath = path.join "MyFolder", "SourceFolder", "Subdir1", "Subdir2", "File"
    expect(PathHelper.makePath(srcFolder, dstFolder, filePath))
    .toEqual(path.join dstFolder, "Subdir1", "Subdir2", "File")
