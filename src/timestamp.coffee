# out: ../lib/timestamp.js
dateformat = require "dateformat"

ts = {}

ts.timestampElements = [
  "yyyy"  # Year as 2015
  "mm"    # Month as 01
  "dd"    # Day as 03
  "HH"    # Hours
  "MM"    # Minutes
  "ss"    # Seconds
]

ts.timestampSeparator = "-"

ts.makeTimestamp = (dateObj) ->
  dateformat.masks.filetimestamp = ts.timestampElements.join(ts.timestampSeparator)
  dateformat dateObj, "filetimestamp"

ts.makeDateObj = (timestamp) ->
  el = timestamp.split(ts.timestampSeparator)
  dateObj = new Date el[0], el[1]-1, el[2], el[3], el[4], el[5]

ts.makeDate = (dateObj) ->
  dateformat dateObj, "dd.mm.yyyy HH:MM:ss"

module.exports = ts
