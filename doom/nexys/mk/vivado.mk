# Conditional bitstream generation
$(BIT_FILE): $(F_TCL) $(F_RTL)
	@echo "Generating bitstream (only if needed)"
	vivado -mode batch -source $(F_TCL)
	cp $(F_PRJ_DIR)/vivado/project_1/project_1.runs/rvfpganexys.bit $@
	@echo "Bitstream generation complete."

# Forced bitstream regeneration when BIT=1
force_gen_bit:
	@echo "Forcing bitstream regeneration due to BIT=1"
	vivado -mode batch -source $(F_TCL)
	cp $(F_PRJ_DIR)/vivado/project_1/project_1.runs/rvfpganexys.bit $(BIT_FILE)
	@echo "Forced bitstream generation complete."
