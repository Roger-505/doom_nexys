PROXY_BIT := $(F_BIT_DIR)/bscan_spi_xc7a100t.bit

flash: $(UB)
	$(ECHO) " FLASH    $(notdir $<)"
	$(Q)$(NEXYS_PROG) -d4 -c "set BINFILE $(UB); \
		set PROXY_BIT $(PROXY_BIT)" -f $(OPENOCD_DIR)/flash.cfg $(REDIRECT)

program: $(BIT)
	$(ECHO) " LOAD     $(notdir $<)"
	$(Q)$(NEXYS_PROG) -c "set BITFILE $<" -f $(OPENOCD_DIR)/program.cfg $(REDIRECT)

debug:
	$(ECHO) " DEBUG"
	st -e $(DB) -x .gdbinit $(ELF) &
	$(Q)$(NEXYS_PROG) -f $(OPENOCD_DIR)/debug.cfg $(REDIRECT)

debug_verilator:
	$(ECHO) " DEBUG"
	st -e $(DB) -x .gdbinit $(ELF) &

help:
	bash $(UTILS_DIR)/help.sh

help-build:
	bash $(UTILS_DIR)/help.sh build

help-sim:
	bash $(UTILS_DIR)/help.sh sim

help-docker:
	bash $(UTILS_DIR)/help.sh docker

help-debug:
	bash $(UTILS_DIR)/help.sh debug

help-options:
	bash $(UTILS_DIR)/help.sh options
