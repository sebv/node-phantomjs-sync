{Sync, MakeSync} = require('make-sync')
phantom = require 'phantom'

buildObjectOptions = (options) ->
  ph:
    mode: options.mode
    exclude: [/^_/, 'exit']
    num_of_args:
      set: 2
  page:
    mode: options.mode
    exclude: [/^_/, 'sendEvent']
    num_of_args:
      evaluate: 1
      set: 2
  
# Builds replacement for the phantom.create method
createReplacement = (options) ->                    
  objectOptions = buildObjectOptions options
  MakeSync \
    (args..., done) ->
      # disassembling and rebuilding child object structure
      # with sync version of objects 
      phantom.create args..., (ph) ->
        _createPage = ph.createPage
        ph.createPage = (args..., done) ->
          _createPage args..., (page) ->
            MakeSync page, objectOptions.page
            done page
        MakeSync ph, objectOptions.ph
        done(ph)
    , options

class Phantom
  constructor: (options) ->
    options = {mode: 'sync'} unless options?
    @create = createReplacement options
     
exports.Phantom = Phantom
exports.Sync= Sync
