# === Vector addresses === #
RESET_VECTOR ?= 0x0
FLASH_ADDR   ?= 0x0

# === Image filtering === 
B_BIN := $(filter %.ub,$(OUTPUTS))
B_VH  := $(filter %.vh,$(OUTPUTS))

# === Build U-boot image === # 
$(B_BIN): $(BIN) | $(BIN_DIR)
	mkimage \
		-A riscv \
		-C none \
		-T standalone \
		-a 0x0 \
		-e $(RESET_VECTOR) \
		-n '$(@F)' \
		-d $< \
		$@
