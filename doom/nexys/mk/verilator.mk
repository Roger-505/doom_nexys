TOP_MODULE = rvfpgasim
VC_FILE =  $(F_VERILATOR)/verilator.vc
VERILATOR_OPTIONS = --trace -Wno-fatal --no-timing

#Assume a local installation if VERILATOR_ROOT is set
VERILATOR_ROOT= ../fpga/verilator
VERILATOR ?= verilator

# Simulation options
WAVE=trace.vcd
WAVE_FILE=$(BUILD_DIR)/$(WAVE)
TIMEOUT=50000
SAVED_WAVES=$(F_VERILATOR)/saved_waves.gtkw
RAM_INIT_FILE=$(B_MEM_S)

# Binaries
VERILATOR_SIM=$(BUILD_DIR)/V$(TOP_MODULE)

# Verilator runtime flags
VERILATOR_FLAGS=
VERILATOR_FLAGS += +vcd=$(WAVE_FILE)
VERILATOR_FLAGS += +timeout=$(TIMEOUT)
# VERILATOR_FLAGS += +jtag_vpi_enable=1
VERILATOR_FLAGS += +ram_init_file=$(RAM_INIT_FILE)

# Make sim
$(VERILATOR_SIM): $(VERILATOR_SIM).mk
	$(ECHO) " MAKE     $(notdir $@)"
	$(Q)$(MAKE) -C $(BUILD_DIR) \
		-j$(shell nproc) $(MAKE_OPTIONS) -f V$(TOP_MODULE).mk \
		Q=$(Q) ECHO=$(ECHO)
	
# Generate makefile
$(VERILATOR_SIM).mk: | $(BUILD_DIR)
	$(ECHO) " VERILATE $(notdir $@)"
	$(Q)$(VERILATOR) -f $(VC_FILE) $(VERILATOR_OPTIONS) $(REDIRECT)
	@sed -i 's|^VERILATOR_ROOT = .*|VERILATOR_ROOT ?= $(VERILATOR_ROOT)|' $@
	@sed -i -E '/^[^#[:space:]].*\.o: .*\.c(pp)?$$/ { N; s|\n\t|\n\t$$(ECHO) " CXX      $$(notdir $$<)"\n\t$$(Q)|; }' $@

run_verilator: | $(BUILD_DIR)
	$(ECHO) " SIM      $(notdir $(VERILATOR_SIM))"
	$(Q)$(VERILATOR_SIM) $(VERILATOR_FLAGS) $(REDIRECT)
	@mv $(WAVE) $(BUILD_DIR)

wave: $(WAVE_FILE) | $(BUILD_DIR)
	$(ECHO) " WAVE     $(notdir $<)"
	$(Q)$(WAVE_VIEWER) -g $(WAVE_FILE) $(SAVED_WAVES) $(REDIRECT)

verilator: $(VERILATOR_SIM) run_verilator wave
