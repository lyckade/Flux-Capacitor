fileExists = require "./fileexists"
_ = require "underscore"

defaultOptions =
  backup: false           #Backup syncs just from src to destination
  backupOverwrite: false  #Overwrites dst files even, when dst newer

  
module.exports = (srcFile, dstFile = "", options = {}) ->
  throw new Error "#{srcFile} file does not exist!" if not fileExists srcFile
  throw new Error "No destination file is given!" if dstFile is ""

  options = _.defaults options, defaultOptions
