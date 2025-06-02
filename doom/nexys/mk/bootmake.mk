FLASH_ADDR ?= 0x0
gen_rom: $(B_MEM)

$(B_ELF): $(B_SRC) | $(BUILD_DIR)
	$(ECHO) " CC       $(B_SRC_DIR)/*.S"
	$(Q)$(CC) -nostartfiles -march=rv32im_zicsr -mabi=ilp32 -T$(B_LD) -o $@ $^

$(B_BIN): $(B_ELF)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -O binary $< $@

$(B_VHD): $(B_BIN)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(PYTHON) $(B_SCRIPT) $< > $@

$(B_MEM): $(B_VHD)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)cp $< $@

$(B_DIS): $(B_ELF)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -d $< > $@

$(B_HEX): $(B_ELF)
	$(ECHO) " OBJCOPY  $(notdir $<) -> $(notdir $@)"
	$(Q)$(OBJCOPY) -O ihex $< $@
