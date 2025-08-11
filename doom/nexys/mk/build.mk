# === Sources ===
include $(COMMON_DIR)/sources.mk
SRC_doom := $(filter-out d_main.c s_sound.c, $(SRC_doom))

# === Flags ===
CFLAGS := -Wall -O3 -march=rv32im -mabi=ilp32 -ffreestanding -flto -nostartfiles \
          -fomit-frame-pointer -Wl,--gc-section --specs=nano.specs \
          -I$(COMMON_DIR) -I$(INC_DIR) -DNORMALUNIX -g -std=gnu99


gen_bin: $(BIN)

# === ELF build ===
$(ELF): $(WADO) | $(BUILD_DIR)
	$(ECHO) " CC       $(COMMON_DIR)/*.c $(SRC_DIR)/*.c"
	$(Q)$(CC) $(CFLAGS) -Wl,-Bstatic,-T,$(LD) -o $@ \
		$(addprefix $(COMMON_DIR)/,$(SRC_doom)) $(SRC)

# === BIN build ===
$(BIN): $(ELF)
	$(ECHO) " OBJCOPY  $< -> $@"
	$(Q)$(OBJCOPY) -O binary $< $@
