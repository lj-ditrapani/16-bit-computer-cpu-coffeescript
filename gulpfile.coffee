gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'

gulp.task 'default', ['lint', 'test']

gulp.task 'lint', ->
  gulp.src ['*.coffee', 'test/*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'test', ->
  gulp.src 'test/*_spec.coffee', {read: false}
    .pipe mocha({reporter: 'landing'})

logit = ->
  e = arguments[0]
  gutil.log(
    "<\u001b[0;33m#{e.plugin}\u001b[0m> " +
    "\u001b[1;31m#{e.name}\u001b[0m"
  )
  stack = e.stack.split('16-bit-computer-cpu/')[1]
  gutil.log(stack)

gulp.task 'compile', ->
  gulp.src 'cpu16bit.coffee'
    .pipe coffee().on('error', logit)
    .pipe gulp.dest('./')
  gulp.src 'test/*_spec.coffee'
    .pipe coffee().on('error', logit)
    .pipe gulp.dest('./test')
