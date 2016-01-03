fileExists = require "./fileexists"
FileCompare = require "./filecompare"
fs = require "fs-extra"
_ = require "underscore"


class FileSync

  constructor: (options = {}) ->
    defaultOptions =
      justBackup: false   #Backup syncs just from src to destination
      noErrors: false     #No error output
    @options = _.defaults options, defaultOptions

  sync: (srcFile, dstFile = "", options = {}) ->
    syncOptions = _.defaults options, @options
    if syncOptions.noErrors is false
      throw new Error "#{srcFile} file does not exist!" if not fileExists srcFile
      throw new Error "No destination file is given!" if dstFile is ""
    sortedFiles = @sortFiles srcFile, dstFile, syncOptions
    @copy sortedFiles[0], sortedFiles[1]

  sortFiles: (srcFile, dstFile, options) ->
    sorted = []
    if not options.justBackup and @fileExists dstFile
      sorted[0] = FileCompare.getNewerFile srcFile, dstFile
      sorted[1] = FileCompare.getOlderFile srcFile, dstFile
    else
      sorted[0] = srcFile
      sorted[1] = dstFile
    sorted

  fileExists: (filePath) ->
    fileExists filePath

  copy: (srcFile, dstFile) ->
    fs.copySync srcFile, dstFile


module.exports = new FileSync
