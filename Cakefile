DEV_DIRS = ['lib','test']
COFFEE_PATHS = DEV_DIRS.concat ['index.coffee']
JS_PATHS = DEV_DIRS.concat ['index.js']

u = require 'sv-cake-utils'

task 'compile', 'Compile All coffee files', ->
  u.coffee.compile COFFEE_PATHS

task 'compile:watch', 'Compile All coffee files and watch for changes', ->
  u.coffee.compile COFFEE_PATHS, watch:true

task 'clean', 'Remove all js files', ->
  u.js.clean JS_PATHS 
  
task 'test', 'Run tests', ->
  u.mocha.test 'test', (status) ->
    process.exit status unless status is 0

task 'grep:dirty', 'Lookup for debugger and console.log in code', ->
  u.grep.debug()
  u.grep.log()
      
task 'kill:all:phantom', 'Kill all phantom process', ->
  u.killAllProc 'phantom'

