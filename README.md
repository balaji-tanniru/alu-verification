# 32-bit ALU Verification

This is my first SystemVerilog verification project.

I designed and verified a 32-bit ALU using Questa Altera Starter Edition.

The ALU supports:

- Addition
- Subtraction
- AND
- OR
- XOR
- Shift left
- Shift right
- Signed comparison

I created a self-checking testbench and used assertions to check the output. I also tested carry, zero and overflow conditions.

The simulation completed successfully, and I saved the waveform as proof.

# Project Files

- `rtl/alu.sv` - ALU design
- `tb/alu.tb.sv` - Testbench and assertions
- `alu_waveform.png` - Simulation waveform

# Waveform

![ALU waveform](alu_waveform.png)

# Tools Used

- SystemVerilog
- Questa Altera Starter Edition
- Visual Studio Code
- Git and GitHub

# What I Learned

I learned how to write an ALU, create test cases, use assertions, check simulation results and view waveforms.
