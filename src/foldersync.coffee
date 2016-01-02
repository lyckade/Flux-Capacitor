fs = require "fs-extra"
path = require "path"

class FolderSync
  constructor: ->

  sync: (srcFolder, dstFolder) ->
    items = []
    fs.walk(srcFolder)
    .on('data', (item) ->
      if item.stats.isFile()
        #FileSync.sync
        console.log item.path
    )
    #.on('end', ->
    #  return items)

module.exports = new FolderSync
