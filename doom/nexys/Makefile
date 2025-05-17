# Cross toolchain prefix
CROSS ?= riscv64-unknown-elf-

# Tools
CC = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
SIZE = $(CROSS)size
NEXYS_PROG = openocd

# Directories
SRC_DIR_doom = ../common/
SRC_DIR_arch = src
INCLUDE_DIR_arch = include
BIN_DIR = bin

# Output files
ELF = $(BIN_DIR)/doom-riscv.elf
BIN = $(BIN_DIR)/doom-riscv.bin
LD_SCRIPT = $(SRC_DIR_arch)/riscv.lds

# Compiler flags
CFLAGS = -Wall \
         -O2 \
         -march=rv32im \
         -mabi=ilp32 \
         -ffreestanding \
         -flto \
         -nostartfiles \
         -fomit-frame-pointer \
         -Wl,--gc-section \
         --specs=nano.specs \
         -I$(SRC_DIR_doom) \
         -I$(INCLUDE_DIR_arch) \
         -DNORMALUNIX

# Include source list
include $(SRC_DIR_doom)sources.mk

# Source filtering
SOURCES_doom := $(filter-out d_main.c s_sound.c, $(SOURCES_doom))
SOURCES_doom_arch := $(wildcard $(SRC_DIR_arch)/*.c $(SRC_DIR_arch)/*.S)

# Default target
all: $(BIN)

# Build ELF
$(ELF): | $(BIN_DIR)
	$(CC) $(CFLAGS) -Wl,-Bstatic,-T,$(LD_SCRIPT) -o $@ \
		$(addprefix $(SRC_DIR_doom),$(SOURCES_doom)) $(SOURCES_doom_arch)
	$(SIZE) $@

# Build BIN from ELF
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

# Ensure bin directory exists
$(BIN_DIR):
	mkdir -p $@

# Clean
clean:
	rm -rf $(BIN_DIR) *.o *.gen.h

# Program targets
prog: $(BIN)
	$(ICEPROG) -o 1M $<

prog_wad: data/doomu.wad
	$(ICEPROG) -o 2M $<

.PHONY: all clean prog prog_wad
.PRECIOUS: $(ELF)
