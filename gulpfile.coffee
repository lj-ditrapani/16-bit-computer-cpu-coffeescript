gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'

gulp.task 'default', ['lint', 'test']

gulp.task 'lint', ->
  gulp.src ['*.coffee', 'test/*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'test', ->
  gulp.src 'test/*_spec.coffee', {read: false}
    .pipe mocha({reporter: 'spec'})

gulp.task 'compile', ->
  gulp.src 'cpu.coffee'
    .pipe coffee()
    .pipe gulp.dest('./')


#.pipe(coffee({bare: true}).on('error', gutil.log))
