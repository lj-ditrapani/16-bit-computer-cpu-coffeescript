###
Author:  Lyall Jonathan Di Trapani
Tests op codes for 16 bit CPU simulator
---------|---------|---------|---------|---------|---------|---------|---------
###

expect = require('chai').expect
_ = require 'lodash'
{CPU, getNibbles} = require '../cpu.coffee'

describe 'makeImmediate8Instruction', ->
  tests = [
    [1, 0x17, 0xF, 0x117F, 'HBY']
    [2, 0xFF, 0x5, 0x2FF5, 'LBY']
  ]
  runTest = (test) ->
    [opCode, immediate, register, instruction, name] = test
    it "makes a #{name} instruction", ->
      i = makeImmediate8Instruction(opCode, immediate, register)
      expect(i).to.equal instruction
  _.each(tests, runTest)

makeImmediate8Instruction = (opCode, immediate, register) ->
  (opCode << 12) | (immediate << 4) | register

describe 'makeInstruction', ->
  tests = [
    [3, 0xF, 0x0, 0x2, 0x3F02, 'LOD']
    [4, 0xE, 0x2, 0x0, 0x4E20, 'STR']
    [5, 0x1, 0x2, 0xD, 0x512D, 'ADD']
    [6, 0x1, 0x2, 0x3, 0x6123, 'SUB']
    [7, 0x7, 0x1, 0x2, 0x7712, 'ADI']
  ]
  _.each tests, (test) ->
    [opCode, a, b, c, instruction, name] = test
    it "makes a #{name} inscruction", ->
      expect(makeInstruction(opCode, a, b, c)).to.equal instruction

makeInstruction = (opCode, a, b, c) ->
  (opCode << 12) | (a << 8) | (b << 4) | c

describe 'getNibbles', ->
  it 'splites a word into 4 4-bit nibbles', ->
    expect(getNibbles(0xABCD)).to.eql [0xA, 0xB, 0xC, 0xD]

  it 'splites another word into 4 4-bit nibbles', ->
    expect(getNibbles(0x7712)).to.eql [0x7, 0x7, 0x1, 0x2]

describe 'CPU', ->
  cpu = registers = rom = ram = null

  runOneInstruction = (instruction, pc = 0) ->
    cpu.pc = pc
    rom[pc] = instruction
    cpu.step()

  testSetByteOperations = (tests, opCode) ->
    _.each tests, (test) ->
      [immediate, register, currentValue, finalValue] = test
      it "sets R#{register} to #{finalValue}", ->
        cpu.registers[register] = currentValue
        i = makeImmediate8Instruction(opCode, immediate, register)
        runOneInstruction i
        expect(cpu.registers[register]).to.equal finalValue

  testAddSub = (opCode, symbol, tests, immediate = false) ->
    runTest = (test, binaryPair) ->
      [a, b, result, finalCarry, finalOverflow] = test
      [initialCarry, initialOverflow] = binaryPair
      it "#{a} #{symbol} #{b} = #{result}", ->
        console.log [
          a, b, result, finalCarry, finalOverflow,
          initialCarry, initialOverflow]
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
        expect(registers[rd]).equal result
        equal cpu.carry, finalCarry, 'carry'
        equal cpu.overflow, finalOverflow, 'overflow'
    _.each tests, (test) ->
      _.each BINARY_PAIRS, (binaryPair) ->
        runTest test, binaryPair

  beforeEach ->
    cpu = new CPU
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
    _.each tests, (test) ->
      [addressRegister, destRegister, address, value] = test
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
    _.each tests, (test) ->
      [addressRegister, valueRegister, address, value] = test
      it "stores R#{valueRegister} into RAM[#{address}]", ->
        registers[addressRegister] = address
        registers[valueRegister] = value
        i = makeInstruction(4, addressRegister, valueRegister, 0)
        runOneInstruction i
        expect(ram[address]).to.equal value
