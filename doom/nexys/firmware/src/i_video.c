/*
 * i_video.c
 *
 * Video system support code
 *
 * Copyright (C) 2021 Sylvain Munaut
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
#include <string.h>

#include "doomdef.h"

#include "i_system.h"
#include "v_video.h"
#include "i_video.h"

#include "config.h"


void
I_InitGraphics(void)
{
	/* Don't need to do anything really ... */

	/* Ok, maybe just set gamma default */
	usegamma = 1;
}

void
I_ShutdownGraphics(void)
{
	/* Don't need to do anything really ... */
}

void
I_SetPalette(byte* palette)
{
	static volatile uint32_t * const video_pal = (void*)(VID_PAL_BASE);
	byte r8, g8, b8;
	uint8_t r4, g4, b4;

	for (int i = 0; i < 256; i++) {
		// Get gamma-corrected 8-bit values
		r8 = gammatable[usegamma][*palette++];
		g8 = gammatable[usegamma][*palette++];
		b8 = gammatable[usegamma][*palette++];

		// Convert 8-bit to 4-bit (right shift by 4)
		r4 = r8 >> 4;
		g4 = g8 >> 4;
		b4 = b8 >> 4;

		// Pack into 12-bit RGB444 format (you can store as 16- or 32-bit as needed)
		// Here stored as 12 bits aligned to lower bits of 32-bit word
		video_pal[i] = (r4 << 8) | (g4 << 4) | b4;
	}
}

void
I_UpdateNoBlit(void)
{
}

void
I_FinishUpdate (void)
{
	/* Copy from RAM buffer to frame buffer */
	memcpy(
		(void*)VID_FB_BASE,
		screens[0],
		SCREENHEIGHT * SCREENWIDTH
	);

	/* Very crude FPS measure (time to render 100 frames */
#if 1
	static int frame_cnt = 0;
	static int tick_prev = 0;

	if (++frame_cnt == 100)
	{
		int tick_now = I_GetTime();
		printf("%d\n", tick_now - tick_prev);
		tick_prev = tick_now;
		frame_cnt = 0;
	}
#endif
}


void
I_WaitVBL(int count)
{
	/* Buys-Wait for VBL status bit */
	static volatile uint32_t * const video_state = (void*)(VID_CTRL_BASE);
	while (!(video_state[0] & (1<<16)));
}


void
I_ReadScreen(byte* scr)
{
	/* FIXME: Would have though reading from VID_FB_BASE be better ...
	 *        but it seems buggy. Not sure if the problem is in the
	 *        gateware
	 */
	memcpy(
		scr,
		screens[0],
		SCREENHEIGHT * SCREENWIDTH
	);
}


#if 0	/* WTF ? Not used ... */
void
I_BeginRead(void)
{
}

void
I_EndRead(void)
{
}
#endif
