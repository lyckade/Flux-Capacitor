# out: ../lib/confSpec.js

Conf = require "./conf"

conf = null
describe "Conf Class", ->
  beforeEach (done) ->
    conf = new Conf()
    done()

  it "should emit an event, when confdata has been refreshed", (done) ->
    refreshMethod = jasmine.createSpy()
    conf.addListener "loaded", refreshMethod
    conf.refreshCallback()
    expect(refreshMethod).toHaveBeenCalled()
    done()

  it "should reload all files of the instance and call refresh callback", (done) ->
    conf.addFile "test1"
    conf.addFile "test2"
    conf.loadFile = jasmine.createSpy("loadFile")
    conf.refreshCallback = jasmine.createSpy("refreshCallback")
    conf.reload()
    expect(conf.loadFile.calls.allArgs()).toEqual([["test1"], ["test2"]])
    expect(conf.refreshCallback).toHaveBeenCalled()
    done()
