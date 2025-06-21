PROXY_BIT := $(F_BIT_DIR)/bscan_spi_xc7a100t.bit
FLASH_ADDR_UBOOT = 0x00c00000
FLASH_ADDR_WAD   = 0x00000000

# Usage: make flash IMG=file.img


flash:
	$(Q)if [ -z "$(IMG)" ]; then \
		echo "Error: IMG is not set. Usage: make flash IMG=filename"; \
		exit 1; \
	fi; \
	FILE_EXT=$$(echo $(IMG) | rev | cut -d. -f1 | rev); \
	if [ "$$FILE_EXT" = "wad" ]; then \
		ADDR=$(FLASH_ADDR_WAD); \
	elif [ "$$FILE_EXT" = "ub" ]; then \
		ADDR=$(FLASH_ADDR_UBOOT); \
	else \
		echo "Unknown image type: $(IMG)"; \
		exit 1; \
	fi; \
	echo " FLASH    $$(basename $(IMG)) at $$ADDR"; \
	$(NEXYS_PROG) -d4 -c "set BINFILE $(IMG); \
		set PROXY_BIT $(PROXY_BIT); \
		set FLASH_ADDR $$ADDR;" -f $(OPENOCD_DIR)/flash.cfg $(REDIRECT)

flash-uboot: $(UB)
	$(Q)$(MAKE) flash IMG=$<

flash-wad: $(WAD)
	$(Q)$(MAKE) flash IMG=$<

program: $(BIT)
	$(ECHO) " LOAD     $(notdir $<)"
	$(Q)$(NEXYS_PROG) -c "set BITFILE $<" -f $(OPENOCD_DIR)/program.cfg $(REDIRECT)

debug:
	$(ECHO) " DEBUG"
	st -e $(DB) -x .gdbinit $(B_ELF) &
	$(Q)$(NEXYS_PROG) -f $(OPENOCD_DIR)/debug.cfg $(REDIRECT)

debug_verilator:
	$(ECHO) " DEBUG"
	st -e $(DB) -x .gdbinit $(ELF) &
