should = require 'should'
# {exec} = require 'child_process'
{Phantom, Sync} = require '../../lib/phantom-sync'
express = require 'express'
temp    = require 'temp'
path    = require 'path'
fs      = require 'fs'

test = (options) ->  
  {app, phantom,p, page} = []    
  
  before (done) ->    
    app = express.createServer()
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
    app.listen()
    phantom = new Phantom options    
    done()

  after (done)->
    p?.exit()
    app?.close() 
    done()

  describe "opening page", ->
    it "creating", (done) ->
      Sync ->
        p = phantom.create()
        page = p.createPage()
        done()

    it "visiting", (done) ->
      Sync ->
        status = page.open "http://127.0.0.1:#{app.address().port}/"
        status.should.be.ok
        done()

    it "title is correct", (done) ->
      Sync ->
        title = page.evaluate -> document.title
        title.should.equal "Test page title"
        done()

  describe "within the page", ->      
    it "can inject Javascript from a file", (done) ->
      Sync ->
        success = page.injectJs 'test/inject.js'
        success.should.be.ok
        done()
    it "evaluating DOM nodes", (done) ->
      Sync ->
        node = page.evaluate (-> document.getElementById('somediv'))
        node.tagName.should.be.equal 'DIV'
        node.id.should.be.equal 'somediv'
        done()
    it "evaluating scripts defined in the header", (done) ->
      Sync ->
        html = page.evaluate -> $('#somediv').html()               
        html = html.replace(/\s\s+/g, "")
        html.should.equal '<div class="anotherdiv">Some page content</div>'
        done()

    it "script taking one parameter", (done) ->
      Sync ->
        res = page.evaluate ( (p1) -> "res:#{p1}" ), 'p12345'
        res.should.equal "res:p12345"
        done()

    it "script taking two parameters", (done) ->
      Sync ->
        res = page.evaluate ( (p1, p2) -> "res:#{p1} #{p2}" ), 'p12345', 678
        res.should.equal "res:p12345 678"
        done()

    it "setting a nested property", (done) ->
      Sync ->
        oldVal = page.set 'settings.loadPlugins', true
        val = page.get 'settings.loadPlugins'
        oldVal.should.equal val
        done()
        
    it "simulating clicks on page locations", (done) ->
      Sync ->
        page.sendEvent 'click', 133, 133
        clicked = page.evaluate -> window.i_got_clicked
        clicked.should.be.ok
        done()

    it "registering an onConsoleMessage handler", (done) ->
      Sync ->
        msg = null
        page.set 'onConsoleMessage', (_msg) -> msg = _msg
        page.evaluate -> console.log "Hello, world!"
        msg.should.equal "Hello, world!"
        done()

    it "rendering the page to a file", (done) ->
      Sync ->      
        fileName = temp.path suffix: '.png'
        page.render fileName
        fs.existsSync(fileName).should.be.ok
        fs.unlink fileName
        done()

describe "phantom-sync", -> \
describe "sync", -> \
describe "page", ->

  for mode in [undefined,'sync',['mixed','args'],['mixed','fibers']]
    describe "#{mode} mode", ->  
      test mode:mode

