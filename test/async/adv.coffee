# same set of tests as phantomjs-node, running 3 times, once for each of the
# potential async modes   

vows    = require 'vows'
assert  = require 'assert'
express = require 'express'
{Phantom} = require '../../lib/phantom-sync'

describe = (name, options) -> vows.describe(name).addBatch(bat options).export(module)

# Make coffeescript not return anything
# This is needed because vows topics do different things if you have a return value
t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

bat = (options) ->

  app = express.createServer()
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

  app.listen()

  phantom = new Phantom options

  "Can create an instance with --load-images=no":
    topic: t -> phantom.create '--load-images=no', (p) => 

      @callback null, p
    
    "which, when you open a page":
      topic: t (p) ->
        test = this
        p.createPage (page) ->
          page.open "http://127.0.0.1:#{app.address().port}/", (status) =>
            setTimeout =>
              test.callback null, page, status
            , 1500

      "and check the settings object":
        topic: t (page) ->
          page.get 'settings', (s) => @callback null, s
        
        "loadImages isn't set": (s) ->
          assert.strictEqual s.loadImages, false
          
           
      "succeeds": (_1, _2, status) ->
        assert.equal status, 'success'
      
      "and check a test image":
        topic: t (page) ->
          page.evaluate (-> document.getElementsByTagName('img')[0]), (img) => @callback null, img
        
        "it doesn't load": (img) ->
          assert.strictEqual img.width, 0, "width should be 0"
          assert.strictEqual img.height, 0, "height should be 0"

    
    teardown: (p) ->
      app.close()
      p.exit()
  
for mode in ['async',['mixed','args'],['mixed','fibers']]
  describe "Adv (#{mode})", {mode: mode}


