# out: ../lib/fileexists.js

fs = require "fs"

module.exports = (filePath) ->
  throw new Error "No file is given." if filePath is ""
  try
    fileStat = fs.statSync filePath
    return true
  catch
    return false
