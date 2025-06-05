# Start from gusanagy image
FROM gusanagy/xilinx-vivado:2024.1-x11
USER root

# General package install
RUN apt-get update
RUN apt-get install locales udev wget unzip git gcc g++ make cmake binutils gtkwave verilator wget gpg yosys iverilog gcc-arm-none-eabi -y

# Configure locales
RUN locale-gen
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen

# Install necessary packages for Vivado
RUN apt-get install libncurses5 libtinfo5 libncurses5-dev libncursesw5-dev ocl-icd-libopencl1 opencl-headers ocl-icd-opencl-dev -y

# Install VScode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN echo 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
RUN rm -f packages.microsoft.gpg
RUN apt-get install software-properties-common -y
RUN apt-get install apt-transport-https -y
RUN apt-get update
RUN apt-get install code python3-venv python3-distutils -y

# Add vivadouser to groups
RUN /sbin/usermod -a -G dialout vivadouser
RUN /sbin/usermod -a -G tty vivadouser
RUN /sbin/usermod -a -G uucp vivadouser
RUN /sbin/usermod -a -G plugdev vivadouser

## RISCV toolchain
# Install dependencies
RUN apt-get update && apt-get install -y \
    autoconf automake autotools-dev curl \
    python3 python3-pip libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison \
    flex texinfo gperf libtool patchutils bc zlib1g-dev \
    libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install tomli

# Clone repo
# RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git
# WORKDIR /opt/riscv-gnu-toolchain
# RUN git checkout 2025.05.30

# Configure construction
# RUN ./configure --prefix=/opt/riscv \
#                --with-arch=rv64imafdc_zicsr \
#                --with-extensions=zicsr \ 
#                --with-abi=lp64d \
#                --enable-multilib \
#                --with-newlib \
#                --disable-shared \
#                --disable-threads \
#                --enable-languages=c,c++ \
#                CFLAGS_FOR_TARGET="-Os -mcmodel=medany" \
#                CXXFLAGS_FOR_TARGET="-Os -mcmodel=medany"

# Build and PATH addition
#RUN make -j$(nproc)

WORKDIR /opt
COPY ./zip/toolchain-riscv.zip .
RUN unzip toolchain-riscv.zip
ENV PATH="/opt/toolchain-riscv/bin:${PATH}"

## OpenOCD
# Install dependencies
RUN apt-get update && apt-get install -y \
    pkg-config libjim-dev libusb-1.0-0 libusb-dev libftdi-dev \
    libgpiod-dev libjaylink-dev u-boot-tools libusb-1.0-0-dev

# Clone the repo
WORKDIR /opt
RUN git clone --recursive https://github.com/riscv/riscv-openocd
WORKDIR riscv-openocd
RUN git checkout openocd64-ad4c3e1

# Configure build
RUN ./bootstrap
RUN ./configure --enable-jtag_vpi --enable-ftdi

# Build
RUN make -j$(nproc)
RUN make install

# Install cable drivers
WORKDIR /home/vivadouser
RUN mkdir data
RUN ./Vivado/2024.1/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers

# VScode and platformio config
RUN mkdir /home/vivadouser/.vscode
RUN chown -R vivadouser:vivadouser /home/vivadouser/.vscode
RUN mkdir /home/vivadouser/.platformio
RUN chown -R vivadouser:vivadouser /home/vivadouser/.platformio

# Add board files and settings 
USER vivadouser
COPY ./zip/master.zip .
RUN unzip master.zip
RUN mkdir /home/vivadouser/Vivado/2024.1/data/boards/board_files
RUN mv /home/vivadouser/vivado-boards-master/new/board_files/* /home/vivadouser/Vivado/2024.1/data/boards/board_files
RUN cd /home/vivadouser
RUN echo "source /home/vivadouser/Vivado/2024.1/settings64.sh" > ~/.bashrc

# Add RVfpga files
COPY ./zip/RVfpga.zip .
RUN unzip RVfpga.zip

# Download Digilent drivers
USER root
WORKDIR /home/vivadouser
RUN bash /home/vivadouser/RVfpga/driversLinux_NexysA7/install_digilent.sh

## Doom
# Install dependencies
RUN apt-get update && apt-get install -y \
    u-boot-tools minicom 

# Permissions for vivadouser
RUN chown -R vivadouser:vivadouser /opt/toolchain-riscv

# Clone Doom repo
USER vivadouser
RUN git clone https://github.com/Roger-505/doom_nexys.git
WORKDIR doom_nexys/doom/nexys

# Enviroment variable defines
ENV DISPLAY=:0
