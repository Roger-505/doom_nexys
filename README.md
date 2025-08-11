Doom classic port to Nexys A7-100T FPGA board
=============================================

This is a port to try and make adapting/running doom to simple
RISC-V platform easier with the code to adapt well split.

A buildable original linux-x11 version will hopefully kept to be
able to test things locally a bit easier.

## Features 

- Playable Doom Shareware version
- Baremetal U-Boot bootloader
- VGA 640x480 support 
- Docker container for compilation and flashing
- Verilator simulation for development

## Usage

For Debian/Ubuntu hosts:

### Linux-X11

### Nexys-A7

## WIP features

As this was initially developed in the span of 2 months for a college course
project, many of the features that I wanted to add could not make it into the final deliverable.
I also had to return the FPGA board back to my college before the next semester started, so I will be unable to work
on this until I get my hands on my own board.
Here are some ideas I have come up with that people might find interesting to work on: 

- Custom loading screen (e.g. Loading...)
- Figure out how incremental synthesis and implementation work on Vivado and integrate it into the current framework
to generate bitstreams faster. I could never figure this one out.
- Portable debug interface (The current one uses stuff that only works on my machine, this is bad!)
- Custom messages displayed on 7-Seg display according to game events
- PS2 keyboard support. I tried to do this, but was not able to figure out key up events, only key downs.
- Full Plug&Play experience (No UART for game controls, game boots from plugging to +5V)
- Expanded I-cache and D-cache (See swerv.config)
- Optimized bitstream (Remove all unused logic from SoC; e.g. Accelerometer SPI, GPIO, etc.)
- Sound support via Mono Audio Out jack
- Custom 3D case for Nexys-A7 board (See this Mega65 emulator case as reference: https://github.com/Roger-505/doom_nexys.git)
- Network support via Ethernet port
- At it's current state, this project barely runs on hardware, but has many bugs that I am aware of. Debugging would
be quite nice.
