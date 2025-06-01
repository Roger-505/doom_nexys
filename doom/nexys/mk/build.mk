# === Sources ===
include $(COMMON_DIR)/sources.mk
SRC_doom := $(filter-out d_main.c s_sound.c, $(SRC_doom))

# === Flags ===
CFLAGS := -Wall -O3 -march=rv32im -mabi=ilp32 -ffreestanding -flto -nostartfiles \
          -fomit-frame-pointer -Wl,--gc-section --specs=nano.specs \
          -I$(COMMON_DIR) -I$(INC_DIR) -DNORMALUNIX -g -ffast-math

gen_bin: $(BIN)

# === WAD build === 
$(WADO): $(WAD) | $(BUILD_DIR)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) \
		--input binary \
		--output elf32-littleriscv \
		--binary-architecture riscv \
		--rename-section .data=.wad,alloc,load,contents,readonly,data \
		$< $@

# === ELF build ===
$(ELF): $(WADO) | $(BUILD_DIR)
	$(ECHO) " CC       $(COMMON_DIR)/*.c $(SRC_DIR)/*.c"
	$(Q)$(CC) $(CFLAGS) -Wl,-Bstatic,-T,$(LD) -o $@ \
		$(addprefix $(COMMON_DIR)/,$(SRC_doom)) $(SRC) $(WADO)

# === BIN build ===
$(BIN): $(ELF)
	$(ECHO) " OBJCOPY  $< -> $@"
	$(Q)$(OBJCOPY) -O binary $< $@
