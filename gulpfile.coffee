gulp = require 'gulp'
runSequence = require 'run-sequence'
tasks = require "#{__dirname}/config/tasks"
{coffee, coffeelint, debug, nodemon} = tasks
{setEnv, setup, tunnel, watch} = tasks

######
# Place to store paths that will be used again
paths =
  env: '.env.json'
  server: 'build/server-assets/server.js'
  coffee:
    compile: 'src/**/*.coffee'
    all: ['src/**/*.coffee']

gulp.task 'default', (cb)->
  runSequence 'setup'
    , ['DB', 'build']
    , ['nodemon', 'debug', 'watch']
    , cb

gulp.task 'build', (cb)->
  runSequence 'coffee', cb

gulp.task 'browserify', ->
  browserify paths.bundle.root, paths.bundle.dest

gulp.task 'coffeelint', ->
  coffeelint paths.coffee.compile

gulp.task 'coffee', ->
  coffee paths.coffee.compile, 'build'

gulp.task 'debug', ->
  debug paths.server

gulp.task 'nodemon', ->
  nodemon paths.server

gulp.task 'setup', (done)->
  setEnv paths.env
  done()
  ######
  # Still need to figure out specific setup questions here
  ######

gulp.task 'DB', ->
  tunnel()

gulp.task 'watch', ->
  watch paths.coffee.all, ->
    runSequence 'coffeelint', 'coffee'
