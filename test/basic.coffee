should = require 'should'
{exec} = require 'child_process'
{makeSync} = require 'make-sync'
{phantom,sync} = require '../lib/phantom-sync'


# having memory leak issues with ps-tree, so making my own
hasChildProcess = makeSync (ppid, done) ->
  exec 'ps -Ao ppid,pid' , (err, stdout, stderr) ->
    count = ('' for line in (stdout.split '\n') \
      when line.trim().match(///^#{ppid}\s+\d+///)).length
    done null, (count > 1)

describe "phantom-sync", \
-> describe "sync", \
-> describe "basics", ->
  ph = null

  after (done)->
    sync ->
      ph?.exitAndWait(500)
      done()

  describe "create an instance", ->
    it "should work", (done) ->
      sync ->
        ph = phantom.create()
        ph.should.have.type 'object'
        done()

    it "version defined and greater than 1.3", (done) ->
      sync ->
        ver = ph.get 'version'
        should.exist ver
        (ver.major >= 1).should.be.true
        (ver.minor >= 3).should.be.true
        done()

  describe "inject Javascript from a file", ->
    it "should work", (done) ->
      sync ->
        success = ph.injectJs 'test/inject.js'
        success.should.be.ok
        done()

  describe "can create a page", ->
    it "should work", (done) ->
      sync ->
        page = ph.createPage()
        page.should.have.type 'object'
        done()

  describe "call exit()", ->

    it "should work", (done) ->
      sync ->
        (hasChildProcess process.pid).should.be.true
        ph.exit()
        setTimeout ->
          sync ->
            (hasChildProcess process.pid).should.be.false
            done()
        , 500


