######################
# === Doom Nexys === #
######################
TARGET    	:= doom_nexys
DATA		:= doom1
BOOT_TARGET := $(TARGET)_rom
BUILD_DIR 	:= build
CROSS     	?= riscv64-unknown-elf-

# === Tools ===
CC       := $(CROSS)gcc
OBJCOPY  := $(CROSS)objcopy
OBJDUMP	 := $(CROSS)objdump
DB		 := $(CROSS)gdb
SIZE     := $(CROSS)size
WAVE_VIEWER := gtkwave
NEXYS_PROG	:= openocd
PYTHON		:= python3
UBOOT_MK	:= mkimage
VIVADO		:= vivado
DOCKER		:= docker compose
DOCKER_IMG  := docker image
DOCKER_VOL	:= docker volume
DOCKER_CONT := docker container
SHELL		:= bash
VCODE		:= code

############################
# === Base Directories === #
############################
BOOT_DIR     := boot
BUILD_DIR    := build
FIRMWARE_DIR := firmware
FPGA_DIR	 := fpga
MK_DIR       := mk
SCRIPTS_DIR  := scripts
COMMON_DIR   := ../common

# === Boot subdirectories ===
B_LD_DIR	  := $(BOOT_DIR)/linker
B_SCRIPTS_DIR := $(BOOT_DIR)/scripts
B_SRC_DIR	  := $(BOOT_DIR)/src

# === Boot subdirectories ===
B_SIM_DIR	  := $(FPGA_DIR)/sim/ram
B_LD_S_DIR	  := $(B_SIM_DIR)/linker
B_SRC_S_DIR	  := $(B_SIM_DIR)/src

# === Firmware subdirectories ===
SRC_DIR	 := $(FIRMWARE_DIR)/src
INC_DIR	 := $(FIRMWARE_DIR)/include
LD_DIR	 := $(FIRMWARE_DIR)/linker
DATA_DIR := $(FIRMWARE_DIR)/data

# === FPGA subdirectories === 
F_BIT_DIR	:= $(FPGA_DIR)/bitstreams
F_XDC_DIR	:= $(FPGA_DIR)/constraints
F_RTL_DIR	:= $(FPGA_DIR)/rtl
F_PRJ_DIR	:= $(FPGA_DIR)/vivado
F_VERILATOR := $(FPGA_DIR)/verilatorSIM

# === Scripts subdirectories ===
OPENOCD_DIR := $(SCRIPTS_DIR)/openocd
UTILS_DIR	:= $(SCRIPTS_DIR)/utils

# === Create build dir === 
$(BUILD_DIR):
	@echo " MKDIR    $(BUILD_DIR)"
	$(Q)mkdir -p $@

#################
# === Files === #
#################

# === Doom outputs ====
ELF  := $(BUILD_DIR)/$(TARGET).elf
BIN  := $(BUILD_DIR)/$(TARGET).bin
UB   := $(BUILD_DIR)/$(TARGET).ub
BIT	 := $(F_BIT_DIR)/$(TARGET).bit

# === Bootrom outputs ===
B_MEM := $(BUILD_DIR)/$(BOOT_TARGET).mem
B_ELF := $(BUILD_DIR)/$(BOOT_TARGET).elf
B_BIN := $(BUILD_DIR)/$(BOOT_TARGET).bin
B_VHD := $(BUILD_DIR)/$(BOOT_TARGET).vh
B_DIS := $(BUILD_DIR)/$(BOOT_TARGET).dis
B_HEX := $(BUILD_DIR)/$(BOOT_TARGET).hex

# === Bootrom sim outputs ===
B_MEM_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.mem
B_ELF_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.elf
B_BIN_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.bin
B_VHD_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.vh
B_DIS_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.dis
B_HEX_S := $(BUILD_DIR)/$(BOOT_TARGET)_sim.hex

# === Boot files === 
B_LD 	 := $(B_LD_DIR)/$(TARGET)_boot.lds
B_SRC    := $(wildcard $(B_SRC_DIR)/*.S)
B_SCRIPT := $(UTILS_DIR)/makehex.py

# === Boot sim files ===
B_LD_S 	 := $(B_LD_S_DIR)/$(TARGET)_boot.lds
B_SRC_S  := $(wildcard $(B_SRC_S_DIR)/*.S)

# === Firmware files ===
INC := $(wildcard $(INC_DIR)/*.h)
LD  := $(LD_DIR)/$(TARGET).lds
SRC := $(wildcard $(SRC_DIR)/*.c) \
       $(wildcard $(SRC_DIR)/*.S) \

# === FPGA files === 
F_XDC := $(wildcard $(F_XDX_DIR)/*.xdc)
F_RTL := $(wildcard $(F_RTL_DIR)/**/*.v) \
         $(wildcard $(F_RTL_DIR)/**/*.vh) \
         $(wildcard $(F_RTL_DIR)/**/*.sv)
F_TCL := $(F_PRJ_DIR)/vivado.tcl
V_TB  := $(F_VERILATOR)/tb.cpp
V_VC  := $(F_VERILATOR)/verilator.vc

# === WAD file ===
WAD	:= $(DATA_DIR)/$(DATA).wad

###########################
# ===    Verbosity    === #
###########################
V ?= 0
ifeq ($(V),1)
Q :=
ECHO := @true
REDIRECT :=
else
Q := @
ECHO := @echo
REDIRECT := > /dev/null 2>&1
endif

###########################
# ===     Docker      === #
###########################
APP 		:= doom_app
CONTAINER	:= doom_container

# === Directories === 
DOCKER_DIR	:= $(SCRIPTS_DIR)/docker

# === Volumes ===
CODE_VOL := code_volume
PLAT_VOL := platformio_volume

###########################
# === Include recipes === #
###########################
MK_FILES := $(wildcard $(MK_DIR)/*.mk)

include $(MK_FILES)

# Default behavior based on SD flag
ifeq ($(SD),1)
all: gen_rom maybe_gen_bit gen_bin gen_ub sd
else
# all: gen_rom maybe_gen_bit gen_bin gen_ub flash-uboot flash-wad program serial
all: gen_rom maybe_gen_bit gen_bin gen_ub flash-uboot flash-wad program serial
endif

# Conditional bitstream generation
ifeq ($(BIT),1)
maybe_gen_bit: force_gen_bit
else
maybe_gen_bit: $(BIT_FILE)
endif


clean:
	@rm -rf $(BUILD_DIR) *jou *log

# Compile with
# sudo PATH=$PATH make clean all
#
# For now...
