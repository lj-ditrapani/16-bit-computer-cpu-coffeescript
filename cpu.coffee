###
Author:  Lyall Jonathan Di Trapani
16 bit CPU simulator
---------|---------|---------|---------|---------|---------|---------|--
###


class CPU
  constructor: ->
    @reset()
    @opCodes = ('END HBY LBY LOD STR ADD SUB ADI SBI AND' +
                 ' ORR XOR NOT SHF BRN SPC').split(' ')

  reset: ->
    @pc = 0
    @registers = (0 for _ in [0...16])
    @rom = (0 for _ in [0...Math.pow(2, 16)])
    @ram = (0 for _ in [0...Math.pow(2, 16)])
    @carry = 0
    @overflow = 0



module.exports = CPU
