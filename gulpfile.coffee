gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'

gulp.task 'default', ['lint', 'test']

gulp.task 'lint', ->
  gulp.src ['*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'test', ->
  gulp.src '*_spec.coffee', {read: false}
    .pipe mocha({reporter: 'spec'})
