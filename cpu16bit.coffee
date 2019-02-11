###
Author:  Lyall Jonathan Di Trapani
16 bit CPU simulator
---------|---------|---------|---------|---------|---------|---------|---------
###


END = 0


getNibbles = (word) ->
  opCode = word >> 12
  a = (word >> 8) & 0xF
  b = (word >> 4) & 0xF
  c = word & 0xF
  [opCode, a, b, c]


isPositiveOrZero = (word) ->
  (word >> 15) is 0


isNegative = (word) ->
  (word >> 15) is 1


isTruePositive = (word) ->
  isPositiveOrZero(word) and (word isnt 0)


hasOverflowedOnAdd = (a, b, sum) ->
  ((isNegative(a) and isNegative(b) and isPositiveOrZero(sum)) or
   (isPositiveOrZero(a) and isPositiveOrZero(b) and isNegative(sum)))


positionOfLastBitShifted = (direction, amount) ->
  if direction is 'right'
    amount - 1
  else
    16 - amount


oneBitWordMask = (position) ->
  Math.pow(2, position)


getShiftCarry = (value, direction, amount) ->
  position = positionOfLastBitShifted(direction, amount)
  mask = oneBitWordMask(position)
  if (value & mask) > 0 then 1 else 0


matchValue = (value, cond) ->
  if ((cond & 0b100) is 0b100) and isNegative(value)
    true
  else if ((cond & 0b010) is 0b010) and (value is 0)
    true
  else if ((cond & 0b001) is 0b001) and isTruePositive(value)
    true
  else
    false


matchFlags = (overflow, carry, cond) ->
  if (cond >= 2) and overflow
    true
  else if ((cond & 1) is 1) and carry
    true
  else if (cond is 0) and (not overflow) and (not carry)
    true
  else
    false


class CPU
  constructor: ->
    @reset()
    @opCodes = ('END HBY LBY LOD STR ADD SUB ADI SBI AND' +
                 ' ORR XOR NOT SHF BRV BRF').split(' ')

  reset: ->
    @pc = 0
    @registers = (0 for _ in [0...16])
    @rom = (0 for _ in [0...Math.pow(2, 16)])
    @ram = (0 for _ in [0...Math.pow(2, 16)])
    @carry = 0
    @overflow = 0

  step: ->
    instruction = @rom[@pc]
    [opCode, a, b, c] = getNibbles instruction
    if opCode is END
      true
    else
      [jump, address] = this[@opCodes[opCode]](a, b, c)
      @pc = if jump is true then address else @pc + 1
      false

  run: ->
    end = false
    while not end
      end = @step()
    return null

  loadProgram: (rom, ram = []) ->
    i = 0
    for value in rom
      @rom[i] = value
      i += 1
    i = 0
    for value in ram
      @ram[i] = value
      i += 1
    return null

  add: (a, b, carry) ->
    sum = a + b + carry
    @carry = Number(sum >= Math.pow(2, 16))
    sum = sum & 0xFFFF
    @overflow = Number(hasOverflowedOnAdd(a, b, sum))
    sum

  HBY: (highNibble, lowNibble, register) ->
    immediate8 = (highNibble << 4) | lowNibble
    value = @registers[register]
    @registers[register] = (immediate8 << 8) | (value & 0x00FF)

  LBY: (highNibble, lowNibble, register) ->
    immediate8 = (highNibble << 4) | lowNibble
    value = @registers[register]
    @registers[register] = (value & 0xFF00) | immediate8

  LOD: (ra, _, rd) ->
    address = @registers[ra]
    @registers[rd] = @ram[address]

  STR: (ra, r2, _) ->
    address = @registers[ra]
    value = @registers[r2]
    @ram[address] = value

  ADD: (r1, r2, rd) ->
    [a, b] = [@registers[r1], @registers[r2]]
    sum = @add a, b, 0
    @registers[rd] = sum

  SUB: (r1, r2, rd) ->
    [a, b] = [@registers[r1], @registers[r2]]
    notB = b ^ 0xFFFF
    diff = @add a, notB, 1
    @registers[rd] = diff

  ADI: (r1, immd, rd) ->
    a = @registers[r1]
    sum = @add a, immd, 0
    @registers[rd] = sum

  SBI: (r1, immd, rd) ->
    a = @registers[r1]
    notB = immd ^ 0xFFFF
    diff = @add a, notB, 1
    @registers[rd] = diff

  AND: (r1, r2, rd) ->
    [a, b] = [@registers[r1], @registers[r2]]
    @registers[rd] = a & b

  ORR: (r1, r2, rd) ->
    [a, b] = [@registers[r1], @registers[r2]]
    @registers[rd] = a | b

  XOR: (r1, r2, rd) ->
    [a, b] = [@registers[r1], @registers[r2]]
    @registers[rd] = a ^ b

  NOT: (r1, _, rd) ->
    a = @registers[r1]
    @registers[rd] = a ^ 0xFFFF

  SHF: (r1, immd, rd) ->
    direction = if immd >= 8 then 'right' else 'left'
    amount = (immd & 7) + 1
    value = @registers[r1]
    @carry = getShiftCarry(value, direction, amount)
    value = if direction is 'right'
      value >> amount
    else
      (value << amount) & 0xFFFF
    @registers[rd] = value

  BRV: (r1, r2, cond) ->
    [value, jumpAddr] = [@registers[r1], @registers[r2]]
    takeJump = matchValue(value, cond & 7)
    if takeJump then [true, jumpAddr] else [false, 0]

  BRF: (r1, r2, cond) ->
    jumpAddr = @registers[r2]
    takeJump = matchFlags(@overflow, @carry, cond & 7)
    if takeJump then [true, jumpAddr] else [false, 0]



export_globals = (exports) ->
  if module?.exports?
    module.exports = exports
  else
    if not ljd?
      window.ljd = {}
    ljd.cpu16bit = exports

export_globals {
  CPU,
  getNibbles,
  positionOfLastBitShifted,
  oneBitWordMask,
  getShiftCarry,
  matchValue,
  matchFlags,
}
