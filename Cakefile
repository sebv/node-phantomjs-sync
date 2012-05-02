DEV_DIRS = ['lib','test']
COFFEE_PATHS = DEV_DIRS.concat ['index.coffee']
JS_PATHS = DEV_DIRS.concat ['index.js']
TEST_ENV = ['test/testing-env.coffee']

u = require 'sv-cake-utils'

task 'compile', 'Compile All coffee files', ->
  u.coffee.compile COFFEE_PATHS

task 'compile:watch', 'Compile All coffee files and watch for changes', ->
  u.coffee.compile COFFEE_PATHS, true

task 'clean', 'Remove all js files', ->
  u.js.clean JS_PATHS 
  u.coffee.compile TEST_ENV
  
task 'test:async', 'Run all async tests (using vows)', ->
  u.coffee.compile TEST_ENV  
  u.vows.test 'test/async' 

task 'test:sync', 'Run all async tests (using vows)', ->
  u.coffee.compile TEST_ENV
  u.mocha.test 'test/sync' 

task 'test', 'Run all sync tests (using mocha)', ->
  u.coffee.compile TEST_ENV
  u.mocha.test 'test/sync', (status)->
    if status is 0
      u.vows.test 'test/async', (status) ->
        if status == 0
          console.log "\n\nAll Tests Succesful.\n\n"
        else
          console.warn "\n\n!!! Async tests failed.\n\n" 
    else 
      console.warn "\n\n!!! Sync tests failed.\n\n" 
        
task 'grep:dirty', 'Lookup for debugger and console.log in code', ->
  u.grep.debug()
  u.grep.log()
      
task 'kill:all:phantom', 'Kill all phantom process', ->
  u.killAllProc 'phantom'

