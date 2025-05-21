PROXY_BIT := $(F_BIT_DIR)/bscan_spi_xc7a100t.bit

flash: $(UB) $(PROXY_BIT)
	openocd -c "set BINFILE $(UB); \
		    	set PROXY_BIT $(PROXY_BIT)" \
			-f $(OPENOCD_DIR)/flash.cfg

program: $(BIT)
	openocd -c "set BITFILE $<" -f $(OPENOCD_DIR)/program.cfg

debug:
	st -e $(DB) -x .gdbinit $(ELF) &
	openocd -f $(OPENOCD_DIR)/debug.cfg
