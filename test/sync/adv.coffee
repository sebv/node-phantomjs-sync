should = require 'should'
express = require 'express'
{Phantom, Sync} = require '../../lib/phantom-sync'

test = (options) ->
  {app, server, phantom, p, page} = []    

  before (done) ->
    app = express()
    app.use express.static __dirname

    app.get '/', (req, res) ->
      res.send """
        <html>
          <head>
            <title>Test page title</title>
          </head>
          <body>
            <img src="/test.gif" />
          </body>
        </html>
      """

    server = app.listen()
    phantom = new Phantom options    
    done()
  
  after (done)->
    p?.exit()
    server?.close() 
    done()

  describe "phantom  instance with --load-images=no", ->
    it "opening  a page", (done) ->
      Sync ->
        p = phantom.create '--load-images=no' 
        page = p.createPage()
        status = page.open "http://127.0.0.1:#{server.address().port}/"
        status.should.be.ok
        done()
    it "checking that loadImages is not set", (done) ->
      Sync ->
        s = page.get 'settings'
        s.loadImages.should.be.false
        done()
      
    it "checking a test image", (done) ->
      Sync ->
        img = page.evaluate -> document.getElementsByTagName('img')[0]
        img.width.should.equal 0
        img.height.should.equal 0
        done()

describe "phantom-sync", -> \
describe "sync", -> \
describe "adv", ->

  for mode in [undefined,'sync',['mixed','args'],['mixed','fibers']]
    describe "#{mode} mode", ->  
      test mode:mode
