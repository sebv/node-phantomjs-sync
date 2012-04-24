###
Cakefile
###
{execFile, spawn, exec} = require 'child_process'

task 'compile', 'Compile all coffee files', ->
  compileAll()

task 'compile:watch', 'Compile all coffee files and watch for change', ->
  compileAll true

task 'clean', 'Remove all js files', ->
  cleanAllJs()

task 'test', 'Run all tests', ->
  testSync (syncStatus) ->
    if syncStatus is 0
      testAsync (asyncStatus) ->
        if(asyncStatus == 0)
          console.log "\n\nAll Tests Succesful.\n\n"
        else
          console.warn "\n\n!!! Async tests failed.\n\n" 
    else 
      console.warn "\n\n!!! Sync tests failed.\n\n" 
      
task 'test:sync', 'Run all sync tests (using mocha)', ->
  compileTestEnv()
  testSync()

task 'test:async', 'Run all async tests (using vows)', ->
  testAsync()
  
task 'grep:dirty', 'Lookup for debugger and console.log in code', ->
  grepDirty()

task 'kill:all:phantom', 'Kill all phantom process', ->
  killAllPhantom()

compileAll = (watch = false) ->
  compileCoffee ['lib','test'], ['index.coffee'], watch

cleanAllJs =  ->
  cleanJs ['lib','test'], ['index.js']

compileCoffee = (dirs , files , watch = false) ->    
  params = ['--compile']
  params.push('--watch') if watch
  params = params.concat dirs 
  params = params.concat files
  _spawn 'coffee', params

compileTestEnv = () ->
  compileCoffee [], ['test/testing-env.coffee'], false

testDirWithMocha = (dir , done) ->    
  execFile 'find', [ dir ] , (err, stdout, stderr) ->
    files = (stdout.split '\n').filter( (name) -> name.match /.+\.coffee/ )
    params = ['-R', 'spec', '--colors'].concat files
    _spawn 'mocha', params, false , done

testDirWithVows = (dir , done) ->    
  execFile 'find', [ dir ] , (err, stdout, stderr) ->
    files = (stdout.split '\n').filter( (name) -> name.match /.+\.coffee/ )
    params = ['--spec'].concat files
    _spawn 'vows', params, false, done

testSync = (done) ->
  testDirWithMocha 'test/sync', done

testAsync = (done) ->
  testDirWithVows 'test/async', done
    
cleanJs = (dirs , files) ->
  execFile 'find', dirs , (err, stdout, stderr) ->
    _files = (stdout.split '\n').filter( (name) -> name.match /.+\.js/ )
    files = files.concat _files
    _spawn 'rm', files, false
  compileTestEnv()

grepDirty = (dirs , word) ->
  execFile 'find', [ '.' ] , (err, stdout, stderr) ->
    files = (stdout.split '\n')\
      .filter( (name) -> not name.match /\/node_modules\//)\
      .filter( (name) -> not name.match /\/\.git\//)\
      .filter( (name) -> 
        ( name.match /\.js$/) or 
        (name.match /\.coffee$/ ) )
    _spawn 'grep', (['console.log'].concat files), false 
    _spawn 'grep', (['debugger'].concat files), false

killAllPhantom = ->
  cmd = "kill -9 `ps -el | grep phantom | grep -v grep | awk '{ print $2 }'`"
  console.log cmd
  _exec cmd
  
_spawn = (cmd,params,exitOnError=true, done) ->
  proc = spawn cmd, params
  proc.stdout.on 'data', (buffer) -> process.stdout.write buffer.toString()
  proc.stderr.on 'data', (buffer) -> process.stderr.write buffer.toString()
  proc.on 'exit', (status) ->
    process.exit(1) if exitOnError and status != 0
    done status if done?

_exec = (cmd,exitOnError=true) ->
  proc = exec cmd
  proc.stdout.on 'data', (buffer) -> process.stdout.write buffer.toString()
  proc.stderr.on 'data', (buffer) -> process.stderr.write buffer.toString()
  proc.on 'exit', (status) ->
    process.exit(1) if exitOnError and status != 0

# unix kill all phantom

