# === Vector addresses === #
RESET_VECTOR ?= 0x00420000
FLASH_ADDR   ?= 0x0

gen_ub: $(UB)

# === Build U-boot image === # 
$(UB): $(BIN) | $(BIN_DIR)
	mkimage \
		-A riscv \
		-C none \
		-T standalone \
		-a 0x0 \
		-e $(RESET_VECTOR) \
		-n '$(@F)' \
		-d $< \
		$@
