#define WISHBONE_RAM_BASE 0x80010000
#define GPIO_BASE	  0x80001400

# Test...

.globl _start
_start:

 li t1,WISHBONE_RAM_BASE
 li t0,WISHBONE_RAM_BASE
 addi t2,t1,4
 loop:
  lw t3,12(t0)
  addi t0,t0,4
  # addi t0,t0,1
  # lw t4,0(t1)
  # lw t5,0(t2)
  j loop
