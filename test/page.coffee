should = require 'should'
# {exec} = require 'child_process'
{phantom,sync} = require '../lib/phantom-sync'
express = require 'express'
temp    = require 'temp'
path    = require 'path'
fs      = require 'fs'

describe "phantom-sync", -> \
describe "sync", -> \
describe "page", ->
  {app, server, ph, page} = {}

  before (done) ->
    app = express()
    app.get '/', (req, res) ->
      res.send """
        <html>
          <head>
            <title>Test page title</title>
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
          </head>
          <body>
            <div id="somediv">
              <div class="anotherdiv">Some page content</div>
            </div>
            <button class="clickme" style="position: absolute; top: 123px; left: 123px; width: 20px; height; 20px" onclick="window.i_got_clicked = true;" />
          </body>
        </html>
      """
    server = app.listen()
    done()

  after (done)->
    sync ->
      ph.exitAndWait(500) if ph?
      server?.close()
      done()

  describe "opening page", ->
    it "creating", (done) ->
      sync ->
        ph = phantom.create()
        page = ph.createPage()
        done()

    it "visiting", (done) ->
      sync ->
        status = page.open "http://127.0.0.1:#{server.address().port}/"
        status.should.be.ok
        done()

    it "title is correct", (done) ->
      sync ->
        title = page.evaluate -> document.title
        title.should.equal "Test page title"
        done()

  describe "within the page", ->
    it "can inject Javascript from a file", (done) ->
      sync ->
        success = page.injectJs 'test/inject.js'
        success.should.be.ok
        done()
    it "evaluating DOM nodes", (done) ->
      sync ->
        node = page.evaluate (-> document.getElementById('somediv'))
        node.tagName.should.be.equal 'DIV'
        node.id.should.be.equal 'somediv'
        done()
    it "evaluating scripts defined in the header", (done) ->
      sync ->
        html = page.evaluate -> $('#somediv').html()
        html = html.replace(/\s\s+/g, "")
        html.should.equal '<div class="anotherdiv">Some page content</div>'
        done()

    it "script taking one parameter", (done) ->
      sync ->
        res = page.evaluate ( (p1) -> "res:#{p1}" ), 'p12345'
        res.should.equal "res:p12345"
        done()

    it "script taking two parameters", (done) ->
      sync ->
        res = page.evaluate ( (p1, p2) -> "res:#{p1} #{p2}" ), 'p12345', 678
        res.should.equal "res:p12345 678"
        done()

    it "setting a nested property", (done) ->
      sync ->
        oldVal = page.set 'settings.loadPlugins', true
        val = page.get 'settings.loadPlugins'
        oldVal.should.equal val
        done()

    unless process.env.TRAVIS_JOB_NUMBER # for some reason, not working on travis
      it "simulating clicks on page locations", (done) ->
        sync ->
          page.sendEvent 'click', 133, 133
          clicked = page.evaluate -> window.i_got_clicked
          clicked.should.be.ok
          done()

    # Looks like there is an issue in phantomjs
    #
    # it "registering an onConsoleMessage handler", (done) ->
    #   sync ->
    #     msg = null
    #     page.set 'onConsoleMessage', (_msg) -> msg = _msg
    #     page.evaluate ->
    #       console.log "Hello, world!"
    #     msg.should.equal "Hello, world!"
    #     done()

    it "rendering the page to a file", (done) ->
      sync ->
        fileName = temp.path suffix: '.png'
        page.render fileName
        fs.existsSync(fileName).should.be.ok
        fs.unlink fileName
        done()

