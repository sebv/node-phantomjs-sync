{Sync, MakeSync} = require('make-sync')
phantom = require 'phantom'
_ = require 'underscore'

buildObjectOptions = (options) ->
  create:
    mode: options.mode
    'sync-return': 'res'
  ph:
    mode: options.mode
    exclude: [/^_/, 'exit']
    'sync-return': 'res'
    num_of_args:
      set: 2
  page:
    mode: options.mode
    exclude: [/^_/, 'sendEvent']
    'sync-return': 'res'
    num_of_args:
      set: 2
  
# Builds replacement for the phantom.create method
createReplacement = (options) ->                    
  objectOptions = buildObjectOptions options
  replacement = (args..., done) ->
    # disassembling and rebuilding child object structure
    # with sync version of objects 
    phantom.create args..., (ph) ->
      _createPage = ph.createPage
      ph.createPage = (args..., done) ->
        _createPage args..., (page) ->
          _evaluate = page.evaluate
          _evaluateSync = MakeSync _evaluate , 
              mode:'sync', 
              'sync-return': 'res'          
          MakeSync page, objectOptions.page
          if _.isEqual options.mode, ['mixed','args']          
            page.evaluate = (args...) ->
              [f,fargs...,cb] = args              
              if (typeof cb) isnt 'function'
                fargs.push cb
                cb = null
              
              unless (typeof cb) is 'function'
                return _evaluateSync.apply page, args
              else
                return _evaluate.apply page, args
          done page
      MakeSync ph, objectOptions.ph
      done(ph)
  MakeSync replacement,  objectOptions.create

class Phantom
  constructor: (options) ->
    options = {mode: 'sync'} unless options?
    @create = createReplacement options
     
exports.Phantom = Phantom
exports.Sync= Sync
