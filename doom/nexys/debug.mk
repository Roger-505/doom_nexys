flash:
	openocd -c "set BINFILE ./bin/doom-riscv.ub" -f ./etc/veerwolf_nexys_write_flash.cfg
