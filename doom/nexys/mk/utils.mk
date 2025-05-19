# === Detect last connected USB device ===
USB_DEV := $(shell lsblk -o NAME,TRAN,TYPE -n | awk '$$2 == "usb" && $$3 == "disk" { print "/dev/" $$1 }' | \
            xargs -I{} stat -c "%Y {}" {} 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2)

# === Directories === 
MNT := /mnt/usb
VIVADO_IMPL := $(F_PRJ_DIR)/impl_1
F_BIT		:= $(filter $(TARGET).bit,$(F_BIT))
TARGET_NAME := boot.bit
sd: detect_usb format mount copy unmount

detect_usb:
	@if [ -z "$(USB_DEV)" ]; then \
		echo "No USB device detected."; \
		exit 1; \
	else \
		echo "Detected USB device: $(USB_DEV)"; \
		MOUNTED=$$(mount | grep "$(USB_DEV)"); \
		if [ -n "$$MOUNTED" ]; then \
			echo "Device is already mounted. Unmounting..."; \
			sudo umount $(USB_DEV); \
		fi \
	fi

format:
	@echo "Formatting $(USB_DEV) as FAT32..."
	sudo mkfs.vfat -F 32 $(USB_DEV)

mount:
	@echo "Mounting USB to $(MOUNT_POINT)..."
	sudo mkdir -p $(MOUNT_POINT)
	sudo mount $(USB_DEV) $(MOUNT_POINT)

copy:
	@echo "Copying $(BITSTREAM) to $(MOUNT_POINT)/$(TARGET_NAME)..."
	sudo cp $(BITSTREAM) $(MOUNT_POINT)/$(TARGET_NAME)
	sync

unmount:
	@echo "Unmounting USB..."
	sudo umount $(MOUNT_POINT)
	@echo "Done."

serial:
	@LAST_TTY=$$(dmesg | grep -oP 'ttyUSB\d+' | tail -1); \
	if [ -z "$$LAST_TTY" ]; then \
		echo "No ttyUSB device found in dmesg."; \
		exit 1; \
	fi; \
	echo "Opening minicom on /dev/$$LAST_TTY"; \
	sudo minicom -D /dev/$$LAST_TTY -b 115200 -8 -o
