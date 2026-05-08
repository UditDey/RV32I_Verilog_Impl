# RISC-V RV32I Implemented in Verilog

This is a basic 3-stage, MCU-class RISC-V CPU written in Verilog.

- Complete RV32I instruction coverage (but no CSRs implemented)
- Simple frontend memory bus
- Verified in Synopsys VCS
- Demo serial output peripheral device
- Tested with sample C programs compiled by GCC

### Architecture:
- [`cpu.v`](cpu.v): Top level module. Presents memory bus, instantiates register file, PC counter and all 3 execution stages
- [`control_unit.v`](control_unit.v): Drives enable signals for the executation stages
- [`fetch_unit.v`](fetch_unit.v): Reads a 32-bit instruction word from the memory bus when enabled. Instruction word is fed into the execution unit
- [`exec_unit.v`](exec_unit.v): Contains the instruction decoder, ALU, branch logic, and data writeback logic
- [`instr_decoder.v`](instr_decoder.v): Decodes the instruction based on which of the 6 RISC-V instruction formats is detected
- [`alu.v`](alu.v): performs arithmetic and logic operations based on the operation type decoded by `instr_decoder.v`
