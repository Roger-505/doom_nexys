Doom classic port to Nexys A7-100T FPGA board
=============================================

This is a port to try and make adapting/running doom to simple
RISC-V platform easier with the code to adapt well split.

A buildable original Linux-x11 version will hopefully kept to be
able to test things locally a bit easier.

- WARNING: The steps detailed ahead might download up to 30GB of data into your host. 
  To make sure the installation does not cause any problems in the future, make sure you have at least 60GB of free memory on your disk.

## Features 

- Playable Doom Shareware version
- Baremetal U-Boot bootloader
- VGA 640x480 support 
- Docker container for compilation and flashing
- Verilator simulation for development

## Dependencies 

### Linux-X11 
- X11 
- Xephyr 
- build-utils 

1. For Debian/Ubuntu hosts, issue the following command to install the above dependencies: 
    ```bash
    sudo apt install build-utils xserver-xephyr
    ```

### Nexys-A7 

- Docker Compose

For Debian/Ubuntu hosts, issue the following command to install the above dependencies: 

1. Clone this repository. Issue the following commands: 
    ```bash
    https://github.com/Roger-505/doom_nexys.git DOOM
    cd $_
    export DOOM_NEXYS=$(pwd)
    ```
2. Navigate to the directory that contains the master `Makefile` for the Nexys-A7 variant. Issue the following command:
    ```bash
    cd $DOOM_NEXYS/doom/nexys
    ```
3. Download the Docker dependencies. Issue the following command: 
    ```bash
    make docker-install_deps
    ```
## Usage

For Debian/Ubuntu hosts, if not done yet already, clone the repository: 

1. Clone this repository.
    ```bash
    https://github.com/Roger-505/doom_nexys.git DOOM
    cd $_
    export DOOM_NEXYS=$(pwd)
    ```

### Linux-X11

1. Navigate to the directory that contains the master `Makefile` for the Linux-X11 variant. Issue the following command: 
    ```bash
    cd $DOOM_NEXYS/doom/linux-x11
    ```
2. Build the Linux-X11 variant. Issue the following command: 
    ```bash
    make -j$(nproc)
    ```
3. Run the Linux-X11 variant. For documentation regarding the options available for this `Makefile`, run  `make help`. Issue the following command:
    ```bash
    make run SIZE=big
    ```

### Nexys-A7

1. Setup the needed .zip files to create the Docker container. You can download them [here](https://drive.google.com/file/d/1fUjV1tkkXkeM8koNcrz5_lHd3CPA93h_/view)
   and extract the file in `$DOOM_NEXYS/doom/nexys/scripts/docker`, or issue the following commands: 
    ```bash
    export FILENAME=doom_nexys_files.zip
    export FILEID=1fUjV1tkkXkeM8koNcrz5_lHd3CPA93h_
    wget --no-check-certificate \
    "https://drive.usercontent.google.com/download?id=${FILEID}&confirm=t" \
     -O "${DOOM_NEXYS}/doom/nexys/scripts/docker/${FILENAME}"
    unzip $DOOM_NEXYS/doom/nexys/scripts/docker/$FILENAME
    ```
2. Navigate to the directory that contains the master `Makefile` for the Nexys-A7 variant. Issue the following command:
    ```bash
    cd $DOOM_NEXYS/doom/nexys
    ```
3. Build the Docker container. Take in mind the following considerations: 
    - This will take some time, as the Docker image used is based on [Gusanagy's Xilinx Vivado image](https://hub.docker.com/r/gusanagy/xilinx-vivado), and Vivado is a heavy program. 
    - The `docker-install_deps` make target used previously does not add $USER to the docker group, so `sudo` will have to be used to execute all Docker related commands. 
    - For documentation regarding the options available for this `Makefile`, run `make help`.

    Issue the following command:
    ```bash
    sudo make docker-build
    ```
4. Change the MODE jumper on the Nexys-A7 board to JTAG, and connect it to the host computer using a microUSB cable. 
5. Start the Docker container. Issue the following command: 
    ```bash
    sudo make docker-start
    ```
6. Start a Docker shell. Issue the following command: 
    ```bash
    sudo make docker-shell
    ```
5. Run the build script for the Doom Nexys-A7 variant. This has to be ran as sudo, as the board will be flashed at this moment. Issue the following command: 
    ```bash
    make all
    ```

## ToDo

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
- Custom 3D case for Nexys-A7 board (See this Mega65 emulator case as reference: https://www.printables.com/model/369914-mega65-nexys-a7-case)
- Network support via Ethernet port
- At it's current state, this project barely runs on hardware, but has many bugs that I am aware of. Debugging would
be quite nice.
