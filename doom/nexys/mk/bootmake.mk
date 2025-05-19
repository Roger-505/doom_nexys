RESET_VECTOR ?= 0
FLASH_ADDR ?= 0x0

gen_rom: $(B_MEM)

$(B_ELF): $(B_SRC) | $(BUILD_DIR)
	$(CC) -nostartfiles -march=rv32im -mabi=ilp32 -T$(B_LD) -o $@ $^

$(B_BIN): $(B_ELF)
	$(OBJCOPY) -O binary $< $@

$(B_VHD): $(B_BIN)
	python3 $(B_SCRIPT) $< > $@

$(B_MEM): $(B_VHD)
	@cp $< $@

$(B_DIS): $(B_ELF)
	$(OBJCOPY) -d $< > $@

$(B_HEX): $(B_ELF)
	$(OBJCOPY) -O ihex $< $@
