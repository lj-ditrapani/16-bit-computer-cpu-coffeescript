###
Author:  Lyall Jonathan Di Trapani
Tests op codes for 16 bit CPU simulator
---------|---------|---------|---------|---------|---------|---------|---------
###

if require?
  expect = require('chai').expect
  _ = require 'lodash'
else
  expect = chai.expect
  _ = window._
{
  CPU,
  getNibbles,
  positionOfLastBitShifted,
  oneBitWordMask,
  getShiftCarry,
  matchValue,
  matchFlags,
} = if require?
  require '../cpu16bit.coffee'
else
  ljd.cpu16bit

makeImmediate8Instruction = (opCode, immediate, register) ->
  (opCode << 12) | (immediate << 4) | register

makeInstruction = (opCode, a, b, c) ->
  (opCode << 12) | (a << 8) | (b << 4) | c

makeCondCode = (strCode) ->
  code = 0
  if ('V' in strCode) or ('C' in strCode) or ('-' in strCode)
    code += 8
    if 'V' in strCode
      code += 2
    if 'C' in strCode
      code += 1
  else
    if 'N' in strCode
      code += 4
    if 'Z' in strCode
      code += 2
    if 'P' in strCode
      code += 1
  code

describe 'test helper functions', ->
  describe 'makeImmediate8Instruction', ->
    tests = [
      [1, 0x17, 0xF, 0x117F, 'HBY']
      [2, 0xFF, 0x5, 0x2FF5, 'LBY']
    ]
    _.each tests, ([opCode, immediate, register, instruction, name]) ->
      it "makes a #{name} instruction", ->
        i = makeImmediate8Instruction(opCode, immediate, register)
        expect(i).to.equal instruction

  describe 'makeInstruction', ->
    tests = [
      [3, 0xF, 0x0, 0x2, 0x3F02, 'LOD']
      [4, 0xE, 0x2, 0x0, 0x4E20, 'STR']
      [5, 0x1, 0x2, 0xD, 0x512D, 'ADD']
      [6, 0x1, 0x2, 0x3, 0x6123, 'SUB']
      [7, 0x7, 0x1, 0x2, 0x7712, 'ADI']
    ]
    _.each tests, ([opCode, a, b, c, instruction, name]) ->
      it "makes a #{name} inscruction", ->
        expect(makeInstruction(opCode, a, b, c)).to.equal instruction

  describe 'makeCondCode', ->
    tests = [
      ['NZP', 0b0111]
      ['ZP', 0b0011]
      ['Z', 0b0010]
      ['P', 0b0001]
      ['VC', 0b1011]
      ['C', 0b1001]
      ['V', 0b1010]
      ['', 0b0000]
      ['-', 0b1000]
    ]
    _.each tests, ([str, code]) ->
      it "(#{str}) => #{code}", ->
        expect(makeCondCode(str)).to.equal code

describe 'getNibbles', ->
  it 'splites a word into 4 4-bit nibbles', ->
    expect(getNibbles(0xABCD)).to.eql [0xA, 0xB, 0xC, 0xD]

  it 'splites another word into 4 4-bit nibbles', ->
    expect(getNibbles(0x7712)).to.eql [0x7, 0x7, 0x1, 0x2]

describe 'positionOfLastBitShifted', ->
  tests = [
    ['left', 1, 15]
    ['right', 1, 0]
    ['left', 4, 12]
    ['right', 4, 3]
    ['left', 8, 8]
    ['right', 8, 7]
  ]
  _.each tests, ([direction, amount, position]) ->
    it "on shift #{direction} by #{amount} = #{position}", ->
      result = positionOfLastBitShifted(direction, amount)
      expect(result).to.equal position

describe 'oneBitWordMask', ->
  tests = [
    [0, 0x0001]
    [1, 0x0002]
    [3, 0x0008]
    [4, 0x0010]
    [8, 0x0100]
    [15, 0x8000]
    [14, 0x4000]
  ]
  _.each tests, ([position, mask]) ->
    it "given position #{position} produces mask #{mask}", ->
      expect(oneBitWordMask(position)).to.equal mask

describe 'getShiftCarry', ->
  tests = [
    ['left', 1, 0x8000, 1]
    ['left', 1, 0x7FFF, 0]
    ['right', 1, 0x0001, 1]
    ['right', 1, 0xFFFE, 0]
    ['left', 4, 0x1000, 1]
    ['right', 4, 0xFFF7, 0]
    ['left', 8, 0xFEFF, 0]
    ['right', 8, 0x0080, 1]
  ]
  _.each tests, ([direction, amount, value, carry]) ->
    it "(#{value}, #{direction}, #{amount}) => #{carry}", ->
      expect(getShiftCarry(value, direction, amount)).to.equal carry

describe 'matchValue', ->
  tests = [
    #  NZP
    [0b000, 0xFFFF, false]
    [0b111, 0xFFFF, true]
    [0b011, 0xFFFF, false]
    [0b100, 0xFFFF, true]
    [0b100, 0x8000, true]
    [0b110, 0x0000, true]
    [0b101, 0x0000, false]
    [0b010, 0x0000, true]
    [0b001, 0x7FFF, true]
    [0b110, 0x7FFF, false]
    [0b101, 0x7FFF, true]
  ]
  _.each tests, ([cond, value, result]) ->
    it "(#{cond}, #{value}) => #{result}", ->
      expect(matchValue(value, cond)).to.equal result

describe 'matchFlags', ->
  tests = [
    #  VC
    [0b00, 0, 0, true]
    [0b00, 1, 0, false]
    [0b00, 0, 1, false]
    [0b11, 0, 1, true]
    [0b11, 1, 0, true]
    [0b11, 1, 1, true]
    [0b11, 0, 0, false]
    [0b10, 0, 0, false]
    [0b10, 0, 1, false]
    [0b10, 1, 0, true]
    [0b10, 1, 1, true]
    [0b01, 0, 0, false]
    [0b01, 0, 1, true]
    [0b01, 1, 0, false]
    [0b01, 1, 1, true]
  ]
  _.each tests, ([cond, overflow, carry, result]) ->
    it "(#{cond}, #{overflow}, #{carry}) => #{result}", ->
      expect(matchFlags(overflow, carry, cond)).to.equal result

describe 'CPU', ->
  cpu = registers = rom = ram = null
  BINARY_PAIRS = [[0, 0], [0, 1], [1, 0], [1, 1]]

  runOneInstruction = (instruction, pc = 0) ->
    cpu.pc = pc
    rom[pc] = instruction
    cpu.step()

  testSetByteOperations = (tests, opCode) ->
    _.each tests, ([immediate, register, currentValue, finalValue]) ->
      it "sets R#{register} to #{finalValue}", ->
        cpu.registers[register] = currentValue
        i = makeImmediate8Instruction(opCode, immediate, register)
        runOneInstruction i
        expect(cpu.registers[register]).to.equal finalValue

  testAddSub = (opCode, symbol, tests, immediate = false) ->
    runTest = ([a, b, result, finalCarry, finalOverflow], binaryPair) ->
      [initialCarry, initialOverflow] = binaryPair
      cv = "#{initialCarry}#{initialOverflow}"
      it "#{a} #{symbol} #{b} = #{result} (cv #{cv})", ->
        [r1, r2, rd] = if initialCarry then [3, 4, 13] else [7, 11, 2]
        cpu.carry = initialCarry
        cpu.overflow = initialOverflow
        registers[r1] = a
        thirdNibble = if immediate
          b
        else
          registers[r2] = b
          r2
        i = makeInstruction(opCode, r1, thirdNibble, rd)
        runOneInstruction i
        expect(registers[rd]).to.equal result
        expect(cpu.carry).to.equal finalCarry
        expect(cpu.overflow).to.equal finalOverflow
    _.each tests, (test) ->
      _.each BINARY_PAIRS, (binaryPair) ->
        runTest test, binaryPair

  testLogicOperation = (opCode, r1, r2, rd, name, tests) ->
    _.each tests, ([a, b, result]) ->
      testName = if name is 'NOT'
        "#{name} #{a} = #{result}"
      else
        "#{a} #{name} #{b} = #{result}"
      it testName, ->
        registers[r1] = a
        registers[r2] = b
        i = makeInstruction(opCode, r1, r2, rd)
        runOneInstruction i
        expect(registers[rd]).to.equal result

  beforeEach ->
    cpu = new CPU()
    ram = cpu.ram
    rom = cpu.rom
    registers = cpu.registers

  describe 'Initial state', ->
    it 'has 65,536 cells of ROM', ->
      expect(rom.length).to.equal 65536

    it 'has RAM initialized to all zeros', ->
      expect([ram[0], ram[0xFFF9]]).to.eql([0, 0])

    it 'has 65,536 cells of RAM', ->
      expect(ram.length).to.equal 65536

    it 'has ROM initialized to all zeros', ->
      expect([rom[0], rom[0xFFF9]]).to.eql([0, 0])

    it 'has 16 registers', ->
      expect(registers.length).to.equal 16

    it 'has 16 op-codes', ->
      expect(cpu.opCodes.length).to.equal 16

    it 'has the program counter set to 0', ->
      expect(cpu.pc).to.equal 0

    it 'has its flags set to 0', ->
      expect([cpu.carry, cpu.overflow]).to.eql [0, 0]

  describe 'END', ->
    beforeEach ->
      rom[0] = 0x0000

    it 'causes step to return true', ->
      expect(cpu.step()).to.be.true

    it 'halts the cpu', ->
      expect(cpu.pc).to.equal 0

  describe 'HBY', ->
    tests = [
      [0x05, 0, 0x0000, 0x0500]
      [0x00, 3, 0xFFFF, 0x00FF]
      [0xEA, 15, 0x1234, 0xEA34]
    ]
    testSetByteOperations tests, 1

  describe 'LBY', ->
    tests = [
      [5, 0, 0, 5]
      [0, 3, 0xFFFF, 0xFF00]
      [0xEA, 15, 0x1234, 0x12EA]
    ]
    testSetByteOperations tests, 2

  describe 'LOD', ->
    tests = [
      [2, 13, 0x0100, 0xFEED]
      [3, 10, 0x1000, 0xFACE]
    ]
    _.each tests, ([addressRegister, destRegister, address, value]) ->
      it "loads RAM[#{address}] into R#{destRegister}", ->
        registers[addressRegister] = address
        ram[address] = value
        i = makeInstruction(3, addressRegister, 0, destRegister)
        runOneInstruction i
        expect(registers[destRegister]).to.equal value

  describe 'STR', ->
    tests = [
      [7, 15, 0x0100, 0xFEED]
      [12, 5, 0x1000, 0xFACE]
      [5, 5, 0x1000, 0x1000]
    ]
    _.each tests, ([addressRegister, valueRegister, address, value]) ->
      it "stores R#{valueRegister} into RAM[#{address}]", ->
        registers[addressRegister] = address
        registers[valueRegister] = value
        i = makeInstruction(4, addressRegister, valueRegister, 0)
        runOneInstruction i
        expect(ram[address]).to.equal value

  describe 'ADD', ->
    tests = [
      [0x0000, 0x0000, 0x0000, 0, 0]
      [0x00FF, 0xFF00, 0xFFFF, 0, 0]
      [0xFFFF, 0x0001, 0x0000, 1, 0]
      [0x0001, 0xFFFF, 0x0000, 1, 0]
      [0xFFFF, 0xFFFF, 0xFFFE, 1, 0]
      [0x8000, 0x8000, 0x0000, 1, 1]
      [0x1234, 0x9876, 0xAAAA, 0, 0]
      [0x1234, 0xDEAD, 0xF0E1, 0, 0]
      [0x7FFF, 0x0001, 0x8000, 0, 1]
      [0x0FFF, 0x7001, 0x8000, 0, 1]
      [0x7FFE, 0x0001, 0x7FFF, 0, 0]
    ]
    testAddSub(5, '+', tests)

  describe 'SUB', ->
    tests = [
      [0x0000, 0x0000, 0x0000, 1, 0]
      [0x0000, 0x0001, 0xFFFF, 0, 0]
      [0x0005, 0x0007, 0xFFFE, 0, 0]
      [0x7FFE, 0x7FFF, 0xFFFF, 0, 0]
      [0xFFFF, 0xFFFF, 0x0000, 1, 0]
      [0xFFFF, 0x0001, 0xFFFE, 1, 0]
      [0x8000, 0x8000, 0x0000, 1, 0]
      [0x8000, 0x7FFF, 0x0001, 1, 1]
      [0xFFFF, 0x7FFF, 0x8000, 1, 0]
      [0x7FFF, 0xFFFF, 0x8000, 0, 1]
      [0x7FFF, 0x0001, 0x7FFE, 1, 0]
    ]
    testAddSub(6, '-', tests)

  describe 'ADI', ->
    tests = [
      [0x0000, 0x0000, 0x0000, 0, 0]
      [0xFFFF, 0x0001, 0x0000, 1, 0]
      [0x7FFF, 0x0001, 0x8000, 0, 1]
      [0x7FFE, 0x0001, 0x7FFF, 0, 0]
      [0xFFFE, 0x000F, 0x000D, 1, 0]
      [0x7FFE, 0x000F, 0x800D, 0, 1]
      [0xFEDF, 0x000E, 0xFEED, 0, 0]
    ]
    testAddSub(7, '+', tests, true)

  describe 'SBI', ->
    tests = [
      [0x0000, 0x0000, 0x0000, 1, 0]
      [0x0000, 0x0001, 0xFFFF, 0, 0]
      [0x8000, 0x0001, 0x7FFF, 1, 1]
      [0x7FFF, 0x0001, 0x7FFE, 1, 0]
      [0x000D, 0x000F, 0xFFFE, 0, 0]
      [0x800D, 0x000F, 0x7FFE, 1, 1]
      [0xFEED, 0x000E, 0xFEDF, 1, 0]
    ]
    testAddSub(8, '-', tests, true)

  describe 'AND', ->
    tests = [
      [0x0000, 0x0000, 0x0000]
      [0xFEED, 0xFFFF, 0xFEED]
      [0xFEED, 0x0F0F, 0x0E0D]
      [0x7BDC, 0xCCE3, 0x48C0]
    ]
    testLogicOperation(9, 14, 7, 0, 'AND', tests)

  describe 'ORR', ->
    tests = [
      [0x0000, 0x0000, 0x0000]
      [0xFEED, 0xFFFF, 0xFFFF]
      [0xF000, 0x000F, 0xF00F]
      [0xC8C6, 0x3163, 0xF9E7]
    ]
    testLogicOperation(0xA, 13, 5, 3, 'OR', tests)

  describe 'XOR', ->
    tests = [
      [0x0000, 0x0000, 0x0000]
      [0xFF00, 0x00FF, 0xFFFF]
      [0x4955, 0x835A, 0xCA0F]
    ]
    testLogicOperation(0xB, 4, 6, 8, 'XOR', tests)

  describe 'NOT', ->
    tests = [
      [0x0000, 0, 0xFFFF]
      [0xFF00, 0, 0x00FF]
      [0x4955, 0, 0xB6AA]
    ]
    testLogicOperation(0xC, 9, 0, 5, 'NOT', tests)

  describe 'SHF', ->
    tests = [
      [0x0704, 0, 0x4, 0x7040, 0]
      [0x090F, 0, 0x1, 0x121E, 0]
      [0x090F, 0, 0x3, 0x4878, 0]
      [0x90F0, 1, 0x4, 0x090F, 0]
      [0x90F1, 1, 0x1, 0x4878, 1]
      [0x450A, 0, 0x7, 0x8500, 0]
      [0x450A, 0, 0x8, 0x0A00, 1]
      [0x450A, 1, 0x8, 0x0045, 0]
    ]
    _.each tests, ([value, direction, amount, result, carry]) ->
      sDirection = if direction then 'right' else 'left'
      it "SHF #{value} #{sDirection} by #{amount} = #{result}", ->
        [r1, rd] = [14, 7]
        cpu.carry = 0
        registers[r1] = value
        immd4 = direction * 8 + (amount - 1)
        i = makeInstruction(13, r1, immd4, rd)
        runOneInstruction i
        expect(registers[rd]).to.equal result
        expect(cpu.carry).to.equal carry

  describe 'BRN', ->
    runBranchTest = (mode, r1, r2, tests) ->
      _.each tests, (test) ->
        messageHead = if mode is 'value'
          [value, condString, takeJump] = test
          "#{value}"
        else # mode is 'flag'
          [overflow, carry, condString, takeJump] = test
          "#{overflow} #{carry}"
        it messageHead + " #{condString} #{takeJump}", ->
          if mode is 'value'
            registers[r1] = value
          else # mode is 'flag'
            cpu.overflow = overflow
            cpu.carry = carry
          jumpAddr = 0x00FF
          registers[r2] = jumpAddr
          condCode = makeCondCode condString
          i = makeInstruction(14, r1, r2, condCode)
          runOneInstruction i
          finalPC = if takeJump then jumpAddr else 0x0001
          expect(cpu.pc).to.equal finalPC

    describe 'on value', ->
      tests = [
        [0xFFFF, '',    false]
        [0xFFFF, 'NZP', true]
        [0xFFFF, 'ZP',  false]
        [0xFFFF, 'N',   true]
        [0x8000, 'N',   true]
        [0x0000, 'NZ',  true]
        [0x0000, 'NP',  false]
        [0x0000, 'Z',   true]
        [0x7FFF, 'P',   true]
        [0x7FFF, 'NZ',  false]
        [0x7FFF, 'NP',  true]
      ]
      runBranchTest('value', 12, 0, tests)

    describe 'on flag', ->
      tests = [
        [0, 0, '-', true]
        [1, 0, '-', false]
        [0, 1, '-', false]
        [0, 1, 'VC', true]
        [1, 0, 'VC', true]
        [1, 1, 'VC', true]
        [0, 0, 'VC', false]
        [0, 0, 'V', false]
        [0, 1, 'V', false]
        [1, 0, 'V', true]
        [1, 1, 'V', true]
        [0, 0, 'C', false]
        [0, 1, 'C', true]
        [1, 0, 'C', false]
        [1, 1, 'C', true]
      ]
      runBranchTest('flag', 11, 1, tests)


  describe 'SPC', ->
    tests = [
      [0, 0x0000, 0x0002]
      [1, 0x00FF, 0x0101]
      [15, 0x0F00, 0x0F02]
    ]
    _.each tests, ([rd, pc, value]) ->
      it "#{rd} #{pc} #{value}", ->
        registers[rd] = 0
        i = makeInstruction(15, 0, 0, rd)
        runOneInstruction(i, pc)
        expect(registers[rd]).to.equal value
