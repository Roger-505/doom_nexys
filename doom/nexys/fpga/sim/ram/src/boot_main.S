#define VID_FB_BASE	0x80010000
#define VID_PAL_BASE	0x80020000
#define VID_CTRL_BASE	0x80020500

.globl _start
_start:

/*
 li t1,VID_PAL_BASE
 li t2,VID_CTRL_BASE
 li t3,0xffffffff
*/

# Disable cache 
li t6, 0xAAAA0000
csrw 0x7c0, t6

li t1,VID_FB_BASE
li t0,0
li a0,0x10000
load_fb_loop:
	sw t0,0(t1)
	addi t0,t0,1
	addi t1,t1,4
	blt t0,a0,load_fb_loop	

li t1,VID_FB_BASE
addi a0,a0,-1
check_fb:
	lw t0,0(t1)
	addi t1,t1,4
	bne t0,a0,check_fb

# Fin de simulación
li t0,0x55555555
bts:
	j bts

/*
 # Disable cache 
 li t6, 0xAAAA0000
 csrw 0x7c0, t6

li t0,0
li a0,256
load_pal_loop:
	sw t0,0(t1)
	addi t0,t0,1
	addi t1,t1,4
	blt t0,a0,load_pal_loop	

li t1,VID_PAL_BASE
addi a0,a0,-1
check_pal:
	lw t0,0(t1)
	addi t1,t1,4
	bne t0,a0,check_pal

# Fin de simulación
li t0,0x55555555
bts:
	j bts
*/ 

 # Verifying that all three wishbones work
#  loop:
	# Erase framebuffer word 0 with 0xffffffff
	# sw t3,0(t0)

	# Erase palette word 0 with 0xffffffff
	# sw t3,0(t1)

	# Busy wait to diferentiate Wishbone transactions
	# li a0,20
	# nop_loop:
		# nop
		# addi a0,a0,-1
		# bne a0,zero,nop_loop
	
	# Load framebuffer word 0 (must be 0xfff...)
	# lw t4,0(t0)
	# addi t0,t0,4

	# Load palette word 0 (must not be 0xfff...)
	# lw t5,0(t1)
	# j loop
