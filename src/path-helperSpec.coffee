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

  it "should check if a folder is a subfolder", ->
    folderPath = path.join "MyFolder"
    subFolder = path.join "MyFolder", "A", "B"
    noSubFolder = path.join "AnotherFolder", "MyFolder", "A"
    expect(ph.isSubfolder folderPath, subFolder).toBe(true)
    expect(ph.isSubfolder folderPath, noSubFolder).toBe(false)
