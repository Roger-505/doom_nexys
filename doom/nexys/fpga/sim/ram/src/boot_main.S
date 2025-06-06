#define WISHBONE_RAM_BASE 0x80130000

.globl _start
_start:

 li s0,WISHBONE_RAM_BASE
 loop:
  lw s1,0(s0)
  addi s0,s0,1
  j loop
