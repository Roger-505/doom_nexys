TOOLCHAIN_PREFIX ?= ${HOME}/.platformio/packages/toolchain-riscv/bin/riscv64-unknown-elf-
RESET_VECTOR ?= 0
FLASH_ADDR ?= 0x0

TARGET = boot_main

SOURCES = boot_main.S spi_uimage_loader.S

all: $(TARGET).mem

$(TARGET).elf: $(SOURCES)
	$(TOOLCHAIN_PREFIX)gcc -nostartfiles -march=rv32im -mabi=ilp32 -Tlink.ld -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

$(TARGET).vh: $(TARGET).bin
	python3 makehex.py $< > $@

$(TARGET).mem: $(TARGET).vh
	@cp $< $@

$(TARGET).dis: $(TARGET).elf
	$(TOOLCHAIN_PREFIX)objdump -d $< > $@

$(TARGET).ihex: $(TARGET).elf
	$(TOOLCHAIN_PREFIX)objcopy -O ihex $< $@

clean:
	rm -f *.mem *.bin *.elf *.vh *.elf
