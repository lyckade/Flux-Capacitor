fs = require "fs-extra"

module.exports=
class FileCopy
  constructor: (@sourceFile, @destinationFile) ->
    if not @checkIfFileExists @sourceFile
      throw new Error "#{@sourceFile} file does not exist!"
    if @destinationFile is ""
      throw new Error "No destination file given!"

  checkIfFileExists: (filepath) ->
    try
      fileStat = fs.statSync filepath
      return true
    catch
      return false

  copyFile: ->
    fs.copySync @sourceFile, @destinationFile
