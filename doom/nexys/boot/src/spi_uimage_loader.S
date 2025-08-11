	/* Assembly program to go into the boot ROM
	   For use with the simple_spi core and standard SPI flash
	   interface-compatible parts (ST M25P16 for example.)

	   Loads an image in the U-boot uimage format from SPI Flash
	   in the the RAM at the address specified in the uimage header.
	   After loading is completed, it will jump to the entry point
	   address specified in the uimage header.

	   To keep it simple, only basic sanity checks are made on the image
	*/

/* Base address of the SPI controller used to communicate with the Flash */
#ifndef SPI_BASE
#define SPI_BASE 0x80001040
#endif

/* 24-bit address in SPI Flash where application image is stored */
#ifndef BOOTROM_ADDR
#define BOOTROM_ADDR 0x00c00000
#endif

/* Flash needs 300 us to warm up from power-on. In practice, this is only an
   issue in simulations as FPGA boot is far longer than 300 us
*/
#ifndef INIT_DELAY
#define INIT_DELAY 700
#endif

#define RETRIES     3

#define SPI_SPCR 0x00
#define SPI_SPSR 0x08
#define SPI_SPDR 0x10
#define SPI_SPER 0x18
#define SPI_SPSS 0x20

#define SPI_SPSS_INIT 0x1
#define SPI_SPSR_RX_CHECK 0x01 /* Check bit 0 is cleared, fifo !empty*/

/* WAD defines */
#define WAD_BASE_ADDR	0x0
#define WAD_SIZE	11159840

	/* Registers used
	ra link register
	t1 temp register
	t2 temp register
	s0 Image size
	s1 Load address
	s2 Reset vector
	s3 Retry counter
	gp SPI master base address
	a3 get_rx_data return value
	t3 temp register
	*/

.globl spi_boot
spi_boot:

#if INIT_DELAY
	li t1, INIT_DELAY
	and t2, zero, zero
1:	addi t2,t2,1
	bne t1, t2, 1b
#endif

	/* Load SPI base address to gp */
	li gp, SPI_BASE

	li s3, RETRIES
spi_init:
	/* Clear slave selects */
	sb	zero, SPI_SPSS(gp)

	/* Set clock divider to 4 (arbitrarily chosen value)
	and enable controller */
	addi	t1, zero, 0x40 | 0x01
	sb	t1, SPI_SPCR(gp)

	/* Set appropriate slave select */
	addi	t1, zero, 1
	sb	t1, SPI_SPSS(gp)

	/* Set command to READ at BOOTROM_ADDR */
	li	a0, ((BOOTROM_ADDR & 0xFF) <<24) | ((BOOTROM_ADDR & 0xFF00) << 8) | ((BOOTROM_ADDR & 0xFF0000) >> 8) | 0x3
	jal	spi_xfer

	/* (Debug) Print bootrom address */
	li a0, BOOTROM_ADDR
	la a5, bin_addr_str
	jal print_label_and_hex

	/* Get magic word */
	jal	spi_xfer

	/* Verify that magic word is (endian-swapped) 0x27051956
	Retry a couple of times before we give up */
	addi	s3, s3, -1
	beqz	s3, boot_fail
	li	t1, 0x56190527
	bne	t1, a1, spi_init

read_header:
	/* Dummy read two words */
	jal	spi_xfer
	jal	spi_xfer

	/* Load image size to s0 */
	jal	spi_xfer
	jal	endian_swap
	mv	s0, a2

	/* Load RAM base address to s1 */
	jal	spi_xfer
	jal	endian_swap
	mv	s1, a2

	/* Load reset vector to s2 */
	jal	spi_xfer
	jal	endian_swap
	mv	s2, a2

	/* Dummy read rest of header */
	jal	spi_xfer //dcrc
	jal	spi_xfer //os, arch, type, comp

	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer
	jal	spi_xfer

	/* Print ACK message */
	la a5, bin_copy
	jal uart_writestr

	mv	a0, s1
	la	a5, bin_addr_str
	jal	print_label_and_hex

	/* Clear number of copied bytes */
	addi	s4, zero, 0
copy_to_ram:
	jal	spi_xfer

	/* Set memory store address */
	add	t1, s1, s4

	/* Write word to RAM */
	sw	a1, 0(t1)

	/* Increase counter */
	addi	s4, s4, 4

	/* Check if file is completely copied */
	bgt	s0, s4, copy_to_ram

	/* Set SPI flash to read from WAD_BASE_ADDR */
	li a0, ((WAD_BASE_ADDR & 0xFF) <<24) | ((WAD_BASE_ADDR & 0xFF00) << 8) | ((WAD_BASE_ADDR & 0xFF0000) >> 8) | 0x3
	jal	spi_xfer

	/* (Debug) Print WAD address */
	li a0, WAD_BASE_ADDR
	la a5, wad_addr_str
	jal print_label_and_hex

	/* Set WAD size */
	li s0,WAD_SIZE

	/* Set WAD base address */
	li s1,WAD_BASE_ADDR

	/* Print ACK message */
	la a5, wad_copy
	jal uart_writestr

	mv	a0, s1
	la	a5, wad_addr_str
	jal	print_label_and_hex

	/* Clear number of copied bytes */
	addi	s4, zero, 0

copy_wad:
	jal spi_xfer

	/* Set memory store address */
	add	t1, s1, s4

	/* Write word to RAM */
	sw	a1, 0(t1)

	/* Increase counter */
	addi	s4, s4, 4

	# Show progress every 1024 bytes
	andi	t2, s4, 1023
	bnez	t2, 1f
	mv	a0, s4
	la	a5, wad_progress_str
	jal	print_label_and_hex

	/* Check if file is completely copied */
1:	bgt	s0, s4, copy_wad
	

	/* Jump to entry point */
	mv	a0, s2
	la	a5, jump_addr_str
	jal	print_label_and_hex

goto_reset:
	jr	s2

	/* Reads ddccbbaa from a1, stores aabbccdd to a2 */
endian_swap:
	slli	a2, a1, 24   // a2 = aa000000
	srli	t1, a1, 8    // t1 = 00ddccbb
	andi	t1, t1, 0xff // t1 = 000000bb
	slli	t1, t1, 16   // t1 = 00bb0000
	or	a2, a2, t1   // a2 = aabb0000

	srli	t1, a1, 16   // t1 = 0000ddcc
	andi	t1, t1, 0xff // t1 = 000000cc
	slli	t1, t1, 8    // t1 = 0000cc00
	or	a2, a2, t1   // a2 = aabbcc00

	srli	t1, a1, 24   // t1 = 000000dd
	or	a2, a2, t1   // a2 = aabbccdd

	ret

spi_xfer:
	/* Loop four times */
	addi	t0, zero, 4

spi_xfer_loop:
	/* Send data in a0[7:0] */
	sb	a0, SPI_SPDR(gp)

spi_xfer_poll:
	/* Wait for data in RX FIFO */
	lbu	t1, SPI_SPSR(gp)
	andi	t1, t1, SPI_SPSR_RX_CHECK
	bnez	t1, spi_xfer_poll

	srli	a1, a1, 8
	lbu	t1, SPI_SPDR(gp)
	slli	t1, t1, 24
	or	a1, a1, t1

	srli	a0, a0, 8
	addi	t0, t0, -1
	bnez	t0, spi_xfer_loop

	ret

bin_copy:
	.string "Copying binary contents to RAM...\r\n"
wad_copy:
	.string "Copying WAD contents to RAM...\r\n"
bin_addr_str:
	.string "Binary base address: "
wad_addr_str:
	.string "WAD base address: "
wad_progress_str:
	.string "WAD bytes copied: "
jump_addr_str:
	.string "Jumping to address: "
magic_word_str:
	.string "U-Boot Endianess Test (Magic Word): "
