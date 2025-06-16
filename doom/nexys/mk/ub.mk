# === Vector addresses === #
# RESET_VECTOR ?= 0x00420000	
RESET_VECTOR ?= 0x00c00000
FLASH_ADDR   ?= 0x0

gen_ub: $(UB)

# === Build U-boot image === # 
$(UB): $(BIN) | $(BIN_DIR)
	$(ECHO) " MKIMAGE  $(notdir $(@))"
	$(Q)$(UBOOT_MK)\
	 -A riscv \
	 -C none \
	 -T standalone \
	 -a 0x0 \
	 -e $(RESET_VECTOR) \
	 -n '$(@F)' \
	 -d $< \
	 $@ $(REDIRECT)
