# node-phantomjs-sync [![Build Status](https://secure.travis-ci.org/sebv/node-phantomjs-sync.png?branch=master)](http://travis-ci.org/sebv/node-phantomjs-sync)

Note: API change in version 1.0.0, see section below.

This is a synchronous version of the [phantom for node](http://github.com/sgentle/phantomjs-node) 
module using [fibers](http://github.com/laverdet/node-fibers). 

## install

```
npm install phantom-sync
```

## upgrade to V1

The main changes are the following:

- 1/ async and mixed mode options have been removed
- 2/ require should be: `{phantom,sync} = require 'phantom-sync'`
- 3/ no need to create a Phantom object

## usage (coffeescript)

```coffeescript
{phantom,sync} = require 'phantom-sync'

sync ->
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

This is the [phantom for node](http://github.com/sgentle/phantomjs-node) API where that callbacks have been transformed into returns. 
Therefore it should be very similar to the [PhantomJS API](http://code.google.com/p/phantomjs/wiki/Interface), 
except for the getters/setters function which need to be called like in the following code:

```coffeescript
page.set 'settings.loadImages', false
page.get 'settings.loadImages'
```
