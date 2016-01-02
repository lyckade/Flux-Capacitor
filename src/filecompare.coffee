fileExists = require "./fileexists"

module.exports.getNewerFile = (firstFile, secondFile) ->
  checkFileIfItExists firstFile

checkFileIfItExists = (filePath) ->
  throw new Error "#{filePath} does not exist!"
