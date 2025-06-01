# === Execute targets for each bash script === 
sd: $(BIT)
	$(ECHO) " SD       $(notdir $(BIT))"
	BITSTREAM=$< $(Q)bash $(UTILS_DIR)/sd.sh

serial:
	$(ECHO) " SERIAL   115200_8N1N /dev/ttyUSB1"
	$(Q)sleep 3
	$(Q)bash $(UTILS_DIR)/serial.sh
