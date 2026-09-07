#!/usr/bin/env bash
set -euo pipefail
mkdir -p sim_build proof
iverilog -g2012 -D__ICARUS__ -o sim_build/alu_smoke rtl/alu.sv tb/alu.tb.sv
vvp sim_build/alu_smoke | tee proof/alu_test.log
grep -q "ALU_TEST_PASS" proof/alu_test.log
