# out: ../lib/dataflux.js

ts = require "./timestamp"

module.exports =
class Dataflux
  constructor: ->
    @ts = ts
