LJD 16-bit processor
====================

Design:
-------

- 16-bit CPU
- 16 X 16-bit registers and program counter (PC)
- Harvard architecture
- 2^16 = 65,536 ROM addresses (16-bit resolution)
- 2^16 = 65,536 RAM addresses (16-bit resolution)
- ROM and RAM are word-addressable
- A word is 16 bits (2 bytes)
- ROM + RAM:  128 KWords = 256 KB = 2 M-bit
- All instructions are 16 bits long
- 16 instructions (4-bit op-code)

The processor instruction set architecture (ISA) can be found in
[doc/ISA.md](doc/ISA.md).


Usage
-----

```bash
npm install ljd-16-bit-cpu
```

From browser:

```html
<script src="node_modules/ljd-16-bit-cpu/cpu16bit.js"></script>
<script>
    var cpu = new ljd.cpu16bit.CPU();
</script>
```

From node.js:

```javascript
var cpu16bit = require('ljd-16-bit-cpu');
var cpu = new cpu16bit.CPU();
```

Run a program

```javascript
// rom is a array of 16-bit integers and length <= 65,536
cpu.loadProgram(rom);
cpu.run();
```

Step through a program

```javascript
// Optionally, the ram contents may also be provided
// ram is a array of 16-bit integers and length <= 65,536
cpu.loadProgram(rom, ram);
cpu.step();
cpu.step();
// ...
```

Developing
----------

```bash
git clone git@github.com:lj-ditrapani/16-bit-computer-cpu.git
cd 16-bit-computer-cpu
npm install
gulp compile
```

This produces cpu16bit.js.

Lint and run tests on node with:

```bash
gulp
```

Open run-specs.html in a browser to run the tests in a browser environment.


Author:  Lyall Jonathan Di Trapani