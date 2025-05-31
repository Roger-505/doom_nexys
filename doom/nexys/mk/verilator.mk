TOP_MODULE = rvfpgasim
VC_FILE =  $(F_VERILATOR)/verilator.vc
VERILATOR_OPTIONS = --trace -Wno-fatal --no-timing

#Assume a local installation if VERILATOR_ROOT is set
ifeq ($(VERILATOR_ROOT),)
VERILATOR ?= verilator
else
VERILATOR ?= $(VERILATOR_ROOT)/bin/verilator
endif

# Simulation options
WAVE_FILE=$(BUILD_DIR)/trace.vcd
TIMEOUT=500000
WAVE_VIEWER=gtkwave
SAVED_WAVES=$(F_VERILATOR)/saved_waves.gtkw

# Binaries
VERILATOR_SIM=V$(TOP_MODULE)

# Make sim
$(VERILATOR_SIM): $(VERILATOR_SIM).mk
	$(MAKE) -C $(BUILD_DIR) $(MAKE_OPTIONS) -f $<
	
# Generate makefile
$(VERILATOR_SIM).mk: | $(BUILD_DIR)
	$(VERILATOR) -f $(VC_FILE) $(VERILATOR_OPTIONS)

# .PHONY : clean_verilator
clean_verilator:
	-rm $(VERILATOR_SIM)*
	-rm $(BUILD_DIR)/*.o
	-rm $(BUILD_DIR)/.d
	-rm $(WAVE_FILE)

run_verilator: | $(BUILD_DIR)
	./V$(TOP_MODULE) +vcd=$(WAVE_FILE) +timeout=$(TIMEOUT)
	@mv $(WAVE_FILE) $(BUILD_DIR)
	$(WAVE_VIEWER) -g $(WAVE_FILE) $(SAVED_WAVES)

verilator: $(VERILATOR_SIM) run_verilator
