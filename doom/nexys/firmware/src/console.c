/*
 * console.c
 *
 * Copyright (C) 2019-2021 Sylvain Munaut
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <stdint.h>

#include "config.h"
#include "mini-printf.h"


struct wb_uart {
	uint32_t data;
	uint32_t clkdiv;
} __attribute__((packed,aligned(4)));

static volatile struct wb_uart * const uart_regs = (void*)(UART_BASE);


void
console_init(void)
{
	uart_regs->clkdiv = 23;	/* 1 Mbaud with clk=25MHz */
}

void
console_putchar(char c)
{
    if (c == '\n') {
        console_putchar('\r');  // prepend carriage return
    }

    while (!(*(volatile uint8_t *)(UART_BASE + REG_LSR) & LSR_THRE)){ /* do nothing */ }; 

	uart_regs->data = (uint32_t)c;
}


char
console_getchar(void)
{
	// Wait until data is ready in the FIFO
	while (!(*(volatile uint8_t *)(UART_BASE + REG_LSR) & 0x01)) {
		/* do nothing */
	}

	// Read the data register (only lower 8 bits are valid)
	return (char)(uart_regs->data & 0xff);
}

int
console_getchar_nowait(void)
{
	// Check if data is available
	if (*(volatile uint8_t *)(UART_BASE + REG_LSR) & 0x01) {
		// Return received character
		return (int)(uart_regs->data & 0xff);
	}

	// No character available
	return -1;
}

void
console_puts(const char *p)
{
	char c;
	while ((c = *(p++)) != 0x00)
		uart_regs->data = c;
}

int
console_printf(const char *fmt, ...)
{
	static char _printf_buf[128];
        va_list va;
        int l;

        va_start(va, fmt);
        l = mini_vsnprintf(_printf_buf, 128, fmt, va);
        va_end(va);

	console_puts(_printf_buf);

	return l;
}
