<!-- Author:  Lyall Jonathan Di Trapani =========|=========|======== -->
Instruction Set Architecture (ISA)
==================================


Instruction Meaning
-------------------

    0 END    Halt computer
    1 HBY    High byte: load byte into high byte of register
    2 LBY    Low byte: load byte into low byte of register
    3 LOD    Load: load value at address into register
    4 STR    Store: store value into address
    5 ADD    Add: add two values
    6 SUB    Subtract: subtract two value
    7 ADI    Add 4-bit immediate
    8 SBI    Subtract 4-bit immediate
    9 AND    And: logical and two values
    A ORR    Or: logical or two values
    B XOR    exclusive or: exclusive or two values
    C NOT    Not: logical not value
    D SHF    Shift: shift bits in register in direction and by ammount
    E BRV    Branch on value (negative, zero, positive)
    F BRF    Branch on flags (carry or overflow)


Instruction operation
--------------------

    0 END
    1 HBY    immd8 -> RD[15-08]
    2 LBY    immd8 -> RD[07-00]
    3 LOD    ram[RS1] -> RD
    4 STR    RS2 -> ram[RS1]
    5 ADD    RS1 + RS2 -> RD
    6 SUB    RS1 - RS2 -> RD
    7 ADI    RS1 + immd4 -> RD
    8 SBI    RS1 - immd4 -> RD
    9 AND    RS1 and RS2 -> RD
    A ORR    RS1 or RS2 -> RD
    B XOR    RS1 xor RS2 -> RD
    C NOT    ! RS1 -> RD
    D SHF    RS1 shifted by immd4 -> RD
    E BRV    if (RS1 matches NZP) then (RS2 -> PC)
    F BRF    if (C or V is set) then (RS2 -> PC)


    Legend:
    -----------------------------------------
    immd8   8-bit immediate value
    immd4   4-bit immediate value
      RS1   Source register (2nd nibble)
      RS2   Source register (3rd nibble)
       RD   Destination register (4th nibble)


### SHF ###

Shift, zero fill

    Carry contains bit of last bit shifted out
    immd4 format
    DAAA
    D is direction:  0 left, 1 right
    AAA is (amount - 1)
    0-7  ->  1-8
    Assembly:
    SHF R7 L 2 RA ->  $D71A
    SHF R5 R 7 R0 ->  $D5E0


### BRV ###

The 4th nibble in a BRV instruction is the condV (condition) nibble.  The most
significant bit is unused.  The other 3 bits represent negative, zero, and
positive respectively.

    0NZP    Check value in RS2 (negative zero positive)
    0111    unconditional jump (jump if value is Neg, Zero or Positive
    0100    jump if RS2 is negative
    0010    jump if RS2 is zero
    0001    jump if RS2 is positive
    0011    jump if RS2 is not negative
    0000    never jump (no operation; NOP)


### BRF ###

The 4th nibble in a BRF instruction is the condF (condition) nibble.  The two
most significant bits are unused.  The other 2 bits represent the state of the
overflow, and carry flags.

    00VC    check the overflow (V), and carry (C) flags
    0000    jump if carry and overflow are *NOT* set (ignore value)
    0010    jump if overflow set (don't care about carry)
    0001    jump if carry set (don't care about overflow)

0011 is not used.
Normally, you want to handle carry or overflow situations differently, hence
0010 and 0001.
However, you may also be interested in ensuring NO exceptions (0000).


Instruction format
------------------

            Mm Reg     01  02  03
    0 END    - ----     0   0   0
    1 HBY    - --W-    UC  UC  RD
    2 LBY    - --W-    UC  UC  RD
    3 LOD    R R-W-   RS1   0  RD
    4 STR    W RR--   RS1 RS2   0
    5 ADD    - RRW-   RS1 RS2  RD
    6 SUB    - RRW-   RS1 RS2  RD
    7 ADI    - R-W-   RS1  UC  RD
    8 SBI    - R-W-   RS1  UC  RD
    9 AND    - RRW-   RS1 RS2  RD
    A ORR    - RRW-   RS1 RS2  RD
    B XOR    - RRW-   RS1 RS2  RD
    C NOT    - R-W-   RS1   0  RD
    D SHF    - R-W-   RS1  DA  RD
    E BRV    - RR-W   RS1 RS2  condV
    F BRF    - -R-W     0 RS2  condF


    Legnd:
    ---------------------------------------------------------------
       Mm   Memory access:    R = read, W = write, - = not accessed
      Reg   Register access:  R = read, W = write, - = not accessed
      RS1   Source register (2nd nibble)
      RS2   Source register (3rd nibble)
       RD   Destination register (4th nibble)
       UC   Unsigned constant (1st or 2nd nibble)
        0   Always zero, unused
       DA   Direction and amount shift bits
    condV   Value condition bits 0NVP
    condF   Flag condition bits 00VC
