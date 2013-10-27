should = require 'should'
express = require 'express'
{phantom, sync} = require '../lib/phantom-sync'

describe "phantom-sync", -> \
describe "sync", -> \
describe "adv", ->
  {app, server, ph, page} = []

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
    done()

  after (done)->
    sync ->
      server?.close()
      ph?.exitAndWait(500)
      done()

  describe "phantom  instance with --load-images=no", ->
    it "opening  a page", (done) ->
      sync ->
        ph = phantom.create '--load-images=no'
        page = ph.createPage()
        status = page.open "http://127.0.0.1:#{server.address().port}/"
        status.should.be.ok
        done()
    it "checking that loadImages is not set", (done) ->
      sync ->
        s = page.get 'settings'
        s.loadImages.should.be.false
        done()

    it "checking a test image", (done) ->
      sync ->
        img = page.evaluate -> document.getElementsByTagName('img')[0]
        img.width.should.equal 0
        img.height.should.equal 0
        done()

