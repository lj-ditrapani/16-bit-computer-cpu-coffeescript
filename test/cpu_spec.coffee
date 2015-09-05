expect = require('chai').expect
{CPU, getNibbles} = require('../cpu.coffee')

describe 'getNibbles', ->
  it 'splites a word into 4 4-bit nibbles', ->
    expect(getNibbles(0xABCD)).to.eql [0xA, 0xB, 0xC, 0xD]

  it 'splites another word into 4 4-bit nibbles', ->
    expect(getNibbles(0x7712)).to.eql [0x7, 0x7, 0x1, 0x2]

describe 'makeInstruction', ->
  tests = [
    [3, 0xF, 0x0, 0x2, 0x3F02, 'LOD']
    [4, 0xE, 0x2, 0x0, 0x4E20, 'STR']
    [5, 0x1, 0x2, 0xD, 0x512D, 'ADD']
    [6, 0x1, 0x2, 0x3, 0x6123, 'SUB']
    [7, 0x7, 0x1, 0x2, 0x7712, 'ADI']
  ]
  for [opCode, a, b, c, instruction, name] in tests
    it "makes a #{name} inscruction", ->
      expect(makeInstruction(opCode, a, b, c)).to.equal instruction

makeInstruction = (opCode, a, b, c) ->
  (opCode << 12) | (a << 8) | (b << 4) | c

describe 'CPU', ->
  cpu = registers = rom = ram = null

  runOneInstruction = (instruction, pc = 0) ->
    cpu.pc = pc
    rom[pc] = instruction
    cpu.step()

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
      rom[0] = 0

    it 'causes step to return true', ->
      expect(cpu.step()).to.be.true

    it 'halts the cpu', ->
      expect(cpu.pc).to.equal 0

  describe 'LOD', ->
    tests = [
      [2, 13, 0x0100, 0xFEED]
      [3, 10, 0x1000, 0xFACE]
    ]
    for [addressRegister, destRegister, address, value] in tests
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
    for [addressRegister, valueRegister, address, value] in tests
      it "stores R#{valueRegister} into RAM[#{address}]", ->
        registers[addressRegister] = address
        registers[valueRegister] = value
        i = makeInstruction(4, addressRegister, valueRegister, 0)
        runOneInstruction i
        expect(ram[address]).to.equal value
