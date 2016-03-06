# out: ../lib/filesync.js

fileExists = require "./fileexists"
FileCompare = require "./filecompare"
fs = require "fs-extra"
_ = require "underscore"

module.exports =
class FileSync

  constructor: (options = {}) ->
    @fileExists = fileExists
    defaultOptions =
      justBackup: false   #Backup syncs just from src to destination
      justNewFiles: false #Copies just files when dstFile don't exists
      noErrors: false     #No error output
      copyOptions:
        preserveTimestamps: true
    @options = _.defaults options, defaultOptions

  sync: (srcFile, dstFile = "", options = {}) ->
    @syncOptions = _.defaults options, @options
    if @syncOptions.noErrors is false
      throw new Error "#{srcFile} file does not exist!" if not @fileExists srcFile
      throw new Error "No destination file is given!" if dstFile is ""
    sortedFiles = @sortFiles srcFile, dstFile, @syncOptions
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

  copy: (srcFile, dstFile) ->
    if not @doNotCopy srcFile, dstFile
      try
        fs.copySync srcFile, dstFile, @options.copyOptions
        #console.log "#{srcFiles} has been copied"
      catch error
        throw error

  doNotCopy: (srcFile, dstFile) ->
    if srcFile is dstFile
      if @syncOptions.noErrors is false
        throw new Error "Source and destination are same file: #{srcFile}"
      return true
    else if @syncOptions.justNewFiles and @fileExists dstFile
      return true
    else
      return false
