# phantomjs-node-sync

This is a synchronous version of the [phantom for node](http://github.com/sgentle/phantomjs-node) 
module using [fibers](http://github.com/laverdet/node-fibers). There are different modes
available, allowing the [PhantomJS](http://www.phantomjs.org/) API to be used synchronously, 
asynchronously, or a mix of both.


## install

```
npm install phantom-sync
```

## read [this](https://github.com/sgentle/phantomjs-node/blob/master/README.markdown) first

really!

## simple usage (coffeescript)

```coffeescript
{Phantom,Sync} = require 'phantom-sync'

phantom = new Phantom 

Sync ->
  ph = phantom.create()
  page = ph.createPage()
  status = page.open "http://www.google.com"
  console.log "status=", status  
  title = page.evaluate ->
    document.title
  console.log "title=", title
  ph.exit()  
```

## API

### async API

Same as [phantom for node](http://github.com/sgentle/phantomjs-node) 

When using the ['mixed','args'] mode, make sure that a 'done' callback is passed to methods 
like 'onConsoleMessage' or 'evaluate', even when not expecting return values, otherwises the 
methods will be called synchronously.

### sync API

This is the [phantom for node](http://github.com/sgentle/phantomjs-node) API where that callbacks have been transformed into returns. 
Therefore it should be very similar to the [PhantomJS API](http://code.google.com/p/phantomjs/wiki/Interface), 
except for the getters/setters function which need to be called like in the following code:

```coffeescript
p.page.set 'settings.loadImages', false
p.page.get 'settings.loadImages'
```

## modes

Please refer to [make-sync](http://github.com/sebv/node-make-sync) for
detailed mode descriptions.

```coffeescript
# sync (default)
phantom = new Phantom   
phantom = new Phantom mode:'sync'   
# async
phantom = new Phantom mode:'async'   
# mixed-args (mixed default)
phantom = new Phantom mode:'mixed'
phantom = new Phantom mode:['mixed','args']
# mixed-fibers
phantom = new Phantom mode:['mixed','fibers']
```


## mixed mode example (coffeescript)

```coffeescript
{Phantom,Sync} = require 'phantom-sync'

phantom = new Phantom mode:'mixed' 

[page,ph] = [] 
# sync calls
Sync ->
  console.log "Step 1"    
  ph = phantom.create()
  page = ph.createPage()
  status = page.open "http://www.google.com"
  console.log "status=", status  
  title = page.evaluate ->
    document.title
  console.log "title=", title

# async calls on the the previous objects
setTimeout ->
  console.log "Step 2"  
  page.open "http://www.yahoo.com", (status) ->  
    console.log "status=", status  
    page.evaluate (-> document.title), (title) -> 
      console.log "title=", title
      ph.exit()
  # using async calls to create a new set of objects
  setTimeout ->
    console.log "Step 3"  
    phantom.create (ph2) ->
      ph2.createPage (page2) ->
        page2.open "http://www.apple.com", (status) ->  
          console.log "status=", status  
          page2.evaluate (-> document.title), (title) -> 
            console.log "title=", title
            ph2.exit()
  , 10000  
, 10000    
```
