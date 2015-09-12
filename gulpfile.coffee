gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
chalk = require 'chalk'
runSequence = require 'run-sequence'

gulp.task 'default', (cb) ->
  runSequence('lint', 'test', cb)

gulp.task 'lint', ->
  gulp.src ['*.coffee', 'test/*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'test', ->
  gulp.src 'test/*-spec.coffee', {read: false}
    .pipe mocha({reporter: 'landing'})

logit = ->
  e = arguments[0]
  gutil.log(
    "<#{chalk.yellow(e.plugin)}> " +
    "#{chalk.bold.red(e.name)}"
  )
  stack = e.stack.split('16-bit-computer-cpu/')[1]
  gutil.log(stack)

gulp.task 'compile', ->
  gulp.src 'cpu16bit.coffee'
    .pipe coffee().on('error', logit)
    .pipe gulp.dest('./')
  gulp.src 'test/*-spec.coffee'
    .pipe coffee().on('error', logit)
    .pipe gulp.dest('./test')
