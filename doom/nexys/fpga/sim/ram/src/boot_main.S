#define VID_FB_BASE	0x80010000
#define VID_PAL_BASE	0x80020000
#define VID_CTRL_BASE	0x80020500

.globl _start
_start:

 li t0,VID_FB_BASE
 li t1,VID_PAL_BASE
 li t2,VID_CTRL_BASE
 li t3,0xffffffff

 # Verifying that all three wishbones work
 loop:
	# Erase palette with 0xffffffff
	sw t3,0(t0)
	addi t0,t0,4

	# Erase framebuffer with 0xffffffff
	sw t3,0(t1)
	addi t1,t1,4

	# Load control reg
	lw t4,0(t2)
	j loop
