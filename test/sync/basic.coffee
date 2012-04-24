should = require 'should'
{exec} = require 'child_process'
{MakeSync} = require 'make-sync'
{Phantom, Sync} = require '../../lib/phantom-sync'

test = (options) ->
  {phantom,p, ver} = {}     
  before (done) ->
    phantom = new Phantom options
    done()
  after (done)->
    p.exit() if p?
    done()        
  describe "create an instance", ->
    it "should work", (done) ->
      Sync ->        
        p = phantom.create()
        p.should.be.a 'object'
        done()

    it "version defined,", (done) ->
      Sync ->
        ver = p.get 'version'      
        should.exist ver
        done()

    it "version greater than or equal to 1.3", (done) ->
      (ver.major >= 1).should.be.true
      (ver.minor >= 3).should.be.true
      done()

  describe "inject Javascript from a file", ->
    it "should work", (done) ->
      Sync ->
        success = p.injectJs 'test/inject.js'
        success.should.be.ok
        done()

  describe "can create a page", ->
    it "should work", (done) ->
      Sync ->
        page = p.createPage()
        page.should.be.a 'object'
        done()

  describe "call exit()", ->
    # having memory leak issues with ps-tree, so making my own 
    hasChildProcess = MakeSync (ppid, done) ->        
      exec 'ps -Ao ppid,pid' , (err, stdout, stderr) ->
        count = ('' for line in (stdout.split '\n') \
          when line.trim().match(///^#{ppid}\s+\d+///)).length
        done (count > 1) 
        
    it "should work", (done) ->
      Sync ->
        (hasChildProcess process.pid).should.be.true
        p.exit()
        setTimeout ->            
          Sync ->
            (hasChildProcess process.pid).should.be.false
            done()
        , 500

describe "phantom-sync", \
-> describe "sync", \
-> describe "basics", ->

  for mode in [undefined,'sync',['mixed','args'],['mixed','fibers']]
    describe "#{mode} mode", ->  
      test mode:mode
  
