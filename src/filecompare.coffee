fileExists = require "./fileexists"


class FileCompare
  constructor: ->
  getNewerFile: (firstFile, secondFile) ->
    @checkInputFiles [firstFile, secondFile]

  checkInputFiles: (inputFiles) ->
    for inputFile in inputFiles
      throw new Error "#{inputFile} does not exist!" if not fileExists inputFile
      throw new Error "No file is given" if inputFile is ""
    true

module.exports = new FileCompare()
