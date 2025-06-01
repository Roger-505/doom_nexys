# Conditional bitstream generation
$(BIT_FILE): $(F_TCL) $(F_RTL)
	$(ECHO) "GEN_BIT $(notdir $(F_TCL))"
	$(Q)$(VIVADO) -mode batch -source $(F_TCL)
	$(Q)cp $(F_PRJ_DIR)/vivado/project_1/project_1.runs/rvfpganexys.bit $@

# Forced bitstream regeneration when BIT=1
force_gen_bit: $(F_TCL) $
	$(ECHO) "GEN_BIT $(notdir $(F_TCL))"
	$(Q)$(VIVADO) -mode batch -source $(F_TCL)
	$(Q)cp $(F_PRJ_DIR)/vivado/project_1/project_1.runs/rvfpganexys.bit $(BIT_FILE)
