TARGET = doom-riscv

# Adjust these as needed
RESET_VECTOR ?= 0x0
FLASH_ADDR ?= 0x0

UBOOT_BIN = $(BIN_DIR)/$(TARGET).ub
UBOOT_VH = $(BIN_DIR)/$(TARGET).ubvh

# Create U-Boot image from binary, place in bin/
$(UBOOT_BIN): $(BIN_DIR)/$(TARGET).bin | $(BIN_DIR)
	mkimage \
		-A riscv \
		-C none \
		-T standalone \
		-a 0x0 \
		-e $(RESET_VECTOR) \
		-n '$(@F)' \
		-d $< \
		$@

# Create Verilog hex file from U-Boot image, placed in bin/
$(UBOOT_VH): $(UBOOT_BIN)
	$(OBJCOPY) --change-addresses=$(FLASH_ADDR) -I binary -O verilog $< $@

# U-Boot image targets grouped for convenience
uboot_images: $(UBOOT_BIN) $(UBOOT_VH)

# Clean U-Boot generated files
clean-ub:
	rm -f $(UBOOT_BIN) $(UBOOT_VH)

.PHONY: uboot_images clean-ub
