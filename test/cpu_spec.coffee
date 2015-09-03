expect = require('chai').expect
CPU = require('../cpu.coffee')

describe 'CPU', ->
  cpu = registers = rom = ram = null

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
