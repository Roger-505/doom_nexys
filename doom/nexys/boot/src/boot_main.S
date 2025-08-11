#define RAM_INIT_DONE 0x8000100A
#define CLK_FREQ_HZ   0x8000103C
#define UART_BASE     0x80002000

#define BAUD_RATE 115200

#define REG_BRDL (4*0x00) /* Baud rate divisor (LSB)        */
#define REG_IER (4*0x01)  /* Interrupt enable reg.          */
#define REG_FCR (4*0x02)  /* FIFO control reg.              */
#define REG_LCR (4*0x03)  /* Line control reg.              */
#define REG_LSR (4*0x05)  /* Line status reg.               */
#define LCR_CS8 0x03   /* 8 bits data size */
#define LCR_1_STB 0x00 /* 1 stop bit */
#define LCR_PDIS 0x00  /* parity disable */

#define LSR_THRE 0x20
#define FCR_FIFO 0x01    /* enable XMIT and RCVR FIFO */
#define FCR_RCVRCLR 0x02 /* clear RCVR FIFO */
#define FCR_XMITCLR 0x04 /* clear XMIT FIFO */
#define FCR_MODE0 0x00 /* set receiver in mode 0 */
#define FCR_MODE1 0x08 /* set receiver in mode 1 */
#define FCR_FIFO_8 0x80  /* 8 bytes in RCVR FIFO */

	/* Registers used
	a4 = UART base
	a5 = String to print
	*/

.globl _start
.globl boot_fail
_start:
	/* Setup mrac CSR

	Mark lower half of 32-bit address space as
	non-cacheable without side effects (mapped to RAM)
	and upper half as non-cacheable with side-effects
	(device memory).

	Bit pattern 1010101010101010_0000000000000000

	*/
	li	t0, 0xAAAA0000
	# csrw	0x7c0, t0
	nop

	jal	uart_init

	la	a5, boot_msg
	jal	uart_writestr

	/* Wait until RAM initialization is done */
	li	t1, RAM_INIT_DONE
1:	lbu	t2, 0(t1)
	beqz	t2, 1b
	la	a5, ram_ok
	jal	uart_writestr

	/* Boot from SPI Flash*/
	j prepare_spi_boot

prepare_spi_boot:
	la	a5, spi_boot_str
	jal	uart_writestr
	j	spi_boot

	/* Spin here on boot failures */
boot_fail:
	la	a5, boot_fail_str
	jal	uart_writestr	
	spin_boot_fail:	
		j spin_boot_fail

uart_init:
	/* Init UART */
	li	a4, UART_BASE

	/* Set DLAB bit in LCR */
	li	t3, 0x80
	sb	t3, REG_LCR(a4)

	/* Set divisor regs */
	li	t3, CLK_FREQ_HZ
	lw	t4, 0(t3)
	li	t3, BAUD_RATE
	divu	t3, t4, t3
	srli	t4, t3, 4
	sb	t4, REG_BRDL(a4)

	/* 8 data bits, 1 stop bit, no parity, clear DLAB */
	li	t3, LCR_CS8 | LCR_1_STB | LCR_PDIS
	sb	t3, REG_LCR(a4)

	li	t3, FCR_FIFO | FCR_MODE0 | FCR_FIFO_8 | FCR_RCVRCLR | FCR_XMITCLR
	sb	t3, REG_FCR(a4)

	/* disable interrupts  */
	sb	zero, REG_IER(a4)
	ret

.globl uart_writestr
uart_writestr: /* Write string at a5 */

	/* Load first byte */
	lb t0, 0(a5)

nextchar:
	/* Write to console and load next char until we get \0 */
putchar:
	/* Check for space in UART FIFO */
	lb	t6, REG_LSR(a4)
	andi	t6, t6, LSR_THRE
	beqz	t6, putchar

	/* Write byte */
	sb	t0, 0(a4)

	addi a5, a5, 1
	lb t0, 0(a5)
	bne t0, zero, nextchar

	ret

    .globl print_label_and_hex
    .globl print_hex
    .globl uart_putchar

/* a5 = label string pointer */
/* a0 = 32-bit number to print */
/* s5 = return address */
print_label_and_hex:
    /* Prologue */ 
    mv s5,ra

    jal uart_writestr       /* print label string */
    jal print_hex           /* print number in hex */
    li  a0, '\r'
    jal uart_putchar
    li  a0, '\n'
    jal uart_putchar

    /* Epilogue */ 
    mv ra,s5
    ret

/* print_hex:
 * prints 8 hex digits (32-bit number in a0)
 * uses uart_putchar to send characters
 * s6 = return address
 */
print_hex:
    /* Epilogue */
    mv s6, ra

    /* We'll print from highest nibble (28) down to lowest nibble (0) */
    li  t0, 28          /* bit shift start */
    li 	t5, 10		/* Compare value for hex chars */
print_hex_loop:
    /* Extract nibble */
    srl t1, a0, t0
    andi t1, t1, 0x0F

    /* Convert nibble to ASCII hex */
    li  t2, '0'
    blt t1, t5, print_hex_digit
    addi t1, t1, -10
    li  t2, 'A'
print_hex_digit:
    add t1, t1, t2

    /* Output character */
    mv  a0, t1
    jal uart_putchar

    /* Decrement bit shift by 4 */
    addi t0, t0, -4
    bgez t0, print_hex_loop

    /* Epilogue */
    mv ra,s6
    ret

/* uart_putchar: sends a single char in a0 over UART */
/* uses REG_LSR and LSR_THRE as UART status bits */
uart_putchar:
    li a4,UART_BASE
1:  lb  t1, REG_LSR(a4)
    andi    t1, t1, LSR_THRE
    beqz    t1, 1b
    sb  a0, 0(a4)
    ret


boot_msg:
	.string "Booting Doom Nexys...\r\n"
ram_ok:
	.string "RAM OK\r\n"
spi_boot_str:
	.string "Booting from SPI Flash\r\n"
boot_fail_str:
	.string "Boot has failed!\r\n"
image_size_str:
	.string "Image size: "
ram_addr_str:
	.string "RAM base address: "
reset_vec_str:
	.string "Reset vector address: "
start_copy_str:
	.string "Starting RAM copy...\r\n"
jump_entry_str:
	.string "Jumping to entry point\r\n"
