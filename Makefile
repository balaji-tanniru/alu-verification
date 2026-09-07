.PHONY: test wave clean
test:
	bash scripts/run_smoke.sh
wave: test
	gtkwave proof/alu_wave.vcd
clean:
	rm -rf sim_build proof/alu_wave.vcd proof/alu_test.log
