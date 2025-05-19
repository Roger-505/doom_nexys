######################
# === Doom Nexys === #
######################
TARGET    := doom_nexys
BUILD_DIR := build
CROSS     ?= riscv64-unknown-elf-

# === Tools ===
CC       := $(CROSS)gcc
OBJCOPY  := $(CROSS)objcopy
SIZE     := $(CROSS)size
NEXYS_PROG := openocd

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

# === Firmware subdirectories ===
SRC_DIR	:= $(FIRMWARE_DIR)/src
INC_DIR	:= $(FIRMWARE_DIR)/include
LD_DIR	:= $(FIRMWARE_DIR)/linker

# === FPGA subdirectories === 
F_BIT_DIR	:= $(FPGA_DIR)/bitstreams
F_XDC_DIR	:= $(FPGA_DIR)/constraints
F_RTL_DIR	:= $(FPGA_DIR)/rtl
F_PRJ_DIR	:= $(FPGA_DIR)/vivado/proj_1

#################
# === Files === #
#################
FORMATS := elf bin ub ubvh
OUTPUTS := $(addprefix $(BUILD_DIR)/$(TARGET)., $(FORMATS))
MK := $(wildcard $(MK_DIR)/*.mk) \
 	  $(COMMON_DIR)/sources.mk

# === Boot files === 
B_LD 	 := $(B_LD_DIR)/$(TARGET)_boot.lds
B_SRC    := $(wildcard $(B_SRC_DIR)/*.mk)
B_SCRIPT := $(B_SCRIPTS_DIR)/$(TARGET)_makehex.py

# === Firmware files ===
INC := $(wildcard $(INC_DIR)/*.h)
LD  := $(LD_DIR_arch)/$(TARGET).lds
SRC := $(wildcard $(SRC_DIR)/*.c) \
       $(wildcard $(SRC_DIR)/*.S) \

# === FPGA files === 
F_BIT := $(wildcard $(F_BIT_DIR)/*.bit)
F_XDC := $(wildcard $(F_XDX_DIR)/*.xdc)
F_RTL := $(wildcard $(F_RTL_DIR)/**/*.v) \
         $(wildcard $(F_RTL_DIR)/**/*.vh) \
         $(wildcard $(F_RTL_DIR)/**/*.sv)
F_TCL := $(F_PRJ_DIR)/$(TARGET).tcl

#########################
# === Include recipes ===
#########################
include $(MK_FILES)

all: 
	touch lmao

# === Precious ===
# ....
