<!-- ====|=========|=========|=========|=========|=========|======== -->
- Change main file name from cpu.coffee & cpu.js to cpu16bit
    - fix gulpfile (compile step)
- require lodash in test and cpu.coffee
- Make browser version
    - check env before requiring lodash
    - check env before requiring cpu.coffee; use ljd if in browser
- lodash is currently only a dev dependency; fix package.json
    - unless you start using it in cpu16bit.coffee
