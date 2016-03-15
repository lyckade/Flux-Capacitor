# out: ../lib/logSpec.js

Log = require "./log"
log = null

describe "Log", ->
  beforeEach ->
    baseTime = new Date 2016, 1, 29, 11, 55, 0
    jasmine.clock().mockDate baseTime
    log = new Log()

  it "should have INFO as default type", ->
    expect(log.makeLogLine "Test").toBe("2016.02.29 11:55:00|INFO|Test")

  it "should able to handle different types", ->
    expect(log.makeLogLine "Test", "TYPE").toBe("2016.02.29 11:55:00|TYPE|Test")
    expect(log.makeLogLine "Test", "TYPE2").toBe("2016.02.29 11:55:00|TYPE2|Test")

  it "should call different callback functions", ->
    spy1 = jasmine.createSpy "spy1"
    spy2 = jasmine.createSpy "spy2"
    log.callbacks = [spy1, spy2]
    log.log "Test"
    expect(spy1).toHaveBeenCalled()
    expect(spy2).toHaveBeenCalled()

  it "should be disabled, when noLog property is true", ->
    spy1 = jasmine.createSpy "spy1"
    log.callbacks = [spy1]
    log.noLog = true
    log.log "Test"
    expect(spy1).not.toHaveBeenCalled()

describe "Asynch Log Events", ->
  spy1 = null
  spy2 = null
  beforeEach (done) ->
    baseTime = new Date 2016, 1, 29, 11, 55, 0
    jasmine.clock().mockDate baseTime
    log = new Log()
    log.callbacks = []
    spy1 = jasmine.createSpy "spy1"
    spy2 = jasmine.createSpy "spy2"
    log.addListener "INFO", spy1
    log.addListener "DEBUG", spy1
    log.addListener "DEBUG", spy2
    done()

  it "should fire an event with the logtype info with one listener", (done) ->
    log.log "Test"
    expect(spy1).toHaveBeenCalledWith("2016.02.29 11:55:00|INFO|Test")
    expect(spy2).not.toHaveBeenCalled()
    done()

  it "should fire an event with the logtype debug with 2 listeners", (done) ->
    log.debugModus = true
    log.debug "Test"
    expect(spy1).toHaveBeenCalledWith("2016.02.29 11:55:00|DEBUG|Test")
    expect(spy2).toHaveBeenCalled()
    done()
