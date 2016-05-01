LJD 16-bit processor
====================

For other implementations, see <https://github.com/lj-ditrapani/16-bit-computer-specification>.

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

```js
var cpu16bit = require('ljd-16-bit-cpu');
var cpu = new cpu16bit.CPU();
```

Run a program

```js
// rom is a array of 16-bit integers and length <= 65,536
cpu.loadProgram(rom);
cpu.run();
```

Step through a program

```js
// Optionally, the ram contents may also be provided
// ram is a array of 16-bit integers and length <= 65,536
cpu.loadProgram(rom, ram);
cpu.step();
cpu.step();
// ...
```

Example program in hex

```js
// This program adds the values in ram[0] and ram[1]
// then stores the result in ram[2]
// 27 + 73 = 100

var rom = [
  0x100A,       // HBY 0x00 RA
  0x200A,       // LBY 0x00 RA
  0x3A01,       // LOD RA R1
  0x201A,       // LBY 0x01 RA
  0x3A02,       // LOD RA R2
  0x5123,       // ADD R1 R2 R3
  0x202A,       // LBY 0x02 RA
  0x4A30,       // STR RA R3
  0x0000        // END
];

var ram = [27, 73, 0];
cpu.loadProgram(rom, ram);
cpu.run();
cpu.ram[2];     // returns 100
```

Developing
----------

```bash
git clone git@github.com:lj-ditrapani/16-bit-computer-cpu-coffeescript.git
cd 16-bit-computer-cpu-coffeescript
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
