# out: ../lib/timestampSpec.js

ts = require "./timestamp"

describe "timestamp", ->

  describe "makeTimestamp", ->
    myDate = null
    timestamp = null
    beforeEach ->
      myDate = new Date 2016, 1, 29, 11, 55, 0
      timestamp = "2016-02-29-11-55-00"

    it "should create a timestamp from a date obj", ->
      expect(ts.makeTimestamp myDate).toBe(timestamp)

    it "should create a dateObj from a timestamp", ->
      expect(ts.makeDateObj timestamp).toEqual(myDate)
