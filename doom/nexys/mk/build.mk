# === Flags ===
CFLAGS := -Wall -O2 -march=rv32im -mabi=ilp32 -ffreestanding -flto -nostartfiles \
          -fomit-frame-pointer -Wl,--gc-section --specs=nano.specs \
          -I$(COMMON_DIR) -I$(INC) -DNORMALUNIX

# === Source filtering ===
SRC_doom := $(filter-out d_main.c s_sound.c, $(SRC_doom))

# === Output filtering ===
ELF	:= $(filter %.elf,$(OUTPUTS))
BIN	:= $(filter %.bin,$(OUTPUTS))

# === ELF build ===
$(ELF): | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Wl,-Bstatic,-T,$(LD_SCRIPT) -o $@ \
		$(addprefix $(COMMON_DIR),$(SRC_doom)) $(SRC)
	$(SIZE) $@

# === BIN build ===
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

# === Create build dir === 
$(BUILD_DIR):
	mkdir -p $@
