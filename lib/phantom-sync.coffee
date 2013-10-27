{sync, makeSync} = require('make-sync')
phantom = require 'phantom'

objectOptions =
  create:
    mode: 'sync'
    'sync-return': 'res'
  ph:
    mode: 'sync'
    exclude: [/^_/, 'exit']
    'sync-return': 'res'
    num_of_args:
      set: 2
  page:
    mode: 'sync'
    exclude: [/^_/, 'sendEvent']
    'sync-return': 'res'
    num_of_args:
      set: 2

_create = (args..., done) ->
  # disassembling and rebuilding child object structure
  # with sync version of objects
  phantom.create args..., (ph) ->
    _createPage = ph.createPage
    ph.createPage = (args..., done) ->
      _createPage args..., (page) ->
        # changing param order in evaluate
        _evaluate = page.evaluate
        page.evaluate = (fn, args..., cb) ->
          _evaluate.apply(page, [fn, cb, args...])
        makeSync page, objectOptions.page
        done page


    # adding 500 ms timeout to exit, cause it does not close cleanly
    ph.exitAndWait = (ms, done) ->
      ph.exit()
      setTimeout ->
        done()
      , ms
    makeSync ph, objectOptions.ph
    done(ph)

_create = makeSync _create, objectOptions.create

phantomSync =
  phantom:
    create: _create
  sync: sync

module.exports = phantomSync

