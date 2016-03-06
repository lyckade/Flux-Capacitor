# out: ../lib/filecompare.js

fileExists = require "./fileexists"
fs = require "fs-extra"


class FileCompare

  getNewerFile: (firstFile, secondFile) ->
    @checkInputFiles [firstFile, secondFile]
    if @getLastModifiedTime(firstFile) >= @getLastModifiedTime(secondFile)
      return firstFile
    else
      return secondFile

  getOlderFile: (firstFile, secondFile) ->
    @checkInputFiles [firstFile, secondFile]
    if @getLastModifiedTime(firstFile) < @getLastModifiedTime(secondFile)
      return firstFile
    else
      return secondFile

  checkInputFiles: (inputFiles) ->
    for inputFile in inputFiles
      throw new Error "#{inputFile} does not exist!" if not fileExists inputFile
      throw new Error "No file is given" if inputFile is ""
    true

  getLastModifiedTime: (filePath) ->
    fs.statSync(filePath).mtime

# Return an instance of FileCompare
module.exports = new FileCompare()
