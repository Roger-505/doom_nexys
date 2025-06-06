FLASH_ADDR ?= 0x0
gen_rom_sim: $(B_MEM_S)

$(B_ELF_S): $(B_SRC_S) | $(BUILD_DIR)
	$(ECHO) " CC       $(B_SRC_S_DIR)/*.S"
	$(Q)$(CC) -nostartfiles -march=rv32im -mabi=ilp32 -T$(B_LD_S) -o $@ $^

$(B_BIN_S): $(B_ELF_S)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -O binary $< $@

$(B_VHD_S): $(B_BIN_S)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(PYTHON) $(B_SCRIPT) $< > $@

$(B_MEM_S): $(B_VHD_S)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)cp $< $@

$(B_DIS_S): $(B_ELF_S)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -d $< > $@

$(B_HEX_S): $(B_ELF_S)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -O ihex $< $@
