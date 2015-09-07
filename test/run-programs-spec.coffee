###
Author:  Lyall Jonathan Di Trapani
Tests to run complete machine language programs for 16 bit CPU simulator
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
} = if require?
  require '../cpu16bit.coffee'
else
  ljd.cpu16bit

describe 'Run full programs', ->
  cpu = registers = rom = ram = null

  beforeEach ->
    cpu = new CPU
    ram = cpu.ram
    rom = cpu.rom
    registers = cpu.registers

  describe 'loadProgram', ->
    it 'loads program into rom', ->
      program = [
        1
        2
        3
        4
        5
      ]
      cpu.loadProgram program
      equal rom[0], 1
      equal rom[4], 5

