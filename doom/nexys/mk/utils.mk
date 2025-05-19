# === Execute targets for each bash script === 
sd: $(BIT)
	BITSTREAM=$< bash $(UTILS_DIR)/sd.sh

serial:
	bash $(UTILS_DIR)/serial.sh
