# RVX10 Instruction Set Extension — Test Plan
CS322M: Computer Architecture — Single-Cycle RISC-V Processor  
Author: **Anshika Raj Yadav (230102111)**  
Target: **RV32I + RVX10 (Custom-0 Opcode)**

---

## 1. Objective

This document outlines the verification strategy for the RVX10 custom instruction set implemented in the single-cycle RISC-V processor.  
Each instruction in the RVX10 extension is validated through simulation to ensure correct datapath operation, ALU behavior, and control signal functionality.

Successful execution is indicated when the processor writes the value **25 (0x19)** to **data memory address 100 (0x64)**, triggering the message:

**Simulation succeeded**


---

## 2. Simulation Environment

| Tool | Version | Command |
|:-----|:---------|:----------|
| **Icarus Verilog** | 11.0 or later | `iverilog -g2012 -o rvx10 src/riscvsingle.sv` |
| **VVP Runtime** | (bundled) | `vvp rvx10` |
| **Optional** | GTKWave | `vvp rvx10 -vcd` for waveform visualization |

---

## 3. Test Strategy

- Verify **functional correctness** of each RVX10 instruction.
- Ensure no interference with base RV32I instructions (add, sub, lw, sw, beq, jal).
- For each instruction:
  1. Load operands using `addi`.
  2. Execute RVX10 instruction.
  3. Store result to data memory using `sw`.
  4. Observe memory writes via `$display` in testbench.
- Final value of **25** stored at address 100 indicates full success.

---

## 4. Instruction Test Cases

| No. | Instruction | Opcode | Test Expression | Expected Result | Verification Method |
|:--:|:-------------|:--------|:----------------|:----------------|:--------------------|
| 1 | **ANDN** | 0001011 | `x5 = x6 & ~x7`, x6=0xF0F0, x7=0x0F0F | `0xF0F0` | Memory write to 0x60 |
| 2 | **ORN** | 0001011 | `x8 = x1 \| ~x2`, x1=0x00FF, x2=0x0F0F | `0xFFF7` | Memory write observed |
| 3 | **XNOR** | 0001011 | `x9 = ~(x3 ^ x4)` | Bitwise XNOR result | Stored value checked |
| 4 | **MIN** | 0001011 | `x10 = min(-3, 5)` | `-3 (0xFFFFFFFD)` | Signed comparison |
| 5 | **MAX** | 0001011 | `x11 = max(-3, 5)` | `5` | Signed comparison |
| 6 | **MINU** | 0001011 | `x12 = minu(10, 250)` | `10` | Unsigned compare result |
| 7 | **MAXU** | 0001011 | `x13 = maxu(10, 250)` | `250` | Unsigned compare result |
| 8 | **ROL** | 0001011 | `x14 = rol(0x81, 1)` | `0x0103` | Rotated left once |
| 9 | **ROR** | 0001011 | `x15 = ror(0x103, 1)` | `0x0081` | Rotated right once |
| 10 | **ABS** | 0001011 | `x16 = abs(-9)` | `9` | Positive absolute value |

---

## 5. Test Program Flow (rvx10.hex)

1. Initialize test registers with known constants.  
2. Execute all 10 RVX10 instructions sequentially.  
3. Use `sw` to store each result at a unique memory address (starting from 0x60).  
4. Jump (`jal`) to self-check routine and back.  
5. Perform a branch (`beq`) test to ensure PC update logic works.  
6. Write **25 (0x19)** to address **0x64 (100)** to mark successful completion.

---

## 6. Verification Criteria

| Stage | What Is Verified | Pass Criteria |
|:------|:------------------|:---------------|
| Decode | ALUControl signal | Matches expected control code for each custom op |
| Execute | ALU output | Correct result vs. model |
| Memory | DataAdr & WriteData | Correct address/data combination |
| End | Final memory state | Value 25 at address 100 |

---

## 7. Example Simulation Log

Expected console output from Icarus Verilog:

Simulation succeeded
VVP Stop(0)
Current simulation time is 195 ticks.


If any instruction or result mismatches, output will show:


---

## 8. Example Memory Map After Successful Run

| Address | Value | Description |
|:--------|:-------|:-------------|
| 0x60 (96) | Intermediate RVX10 result | Example: MIN result |
| 0x64 (100) | 0x00000019 | Success signature (25) |

---

## 9. Regression and Coverage

- Each custom instruction tested with both **positive/negative** and **unsigned/signed** operands.  
- ROL/ROR validated for 1-bit and multi-bit rotations.  
- Observed signals:
  - `RegWrite`, `ALUSrc`, `MemWrite`, `ResultSrc` for datapath correctness.
  - `ALUControl` and `Zero` for decode accuracy.
- All tests re-run after each RTL update to ensure no regression failures.

---

## 10. Conclusion

This test plan ensures comprehensive functional verification of the **RVX10 custom arithmetic and logical instructions** integrated into the single-cycle RISC-V processor.  
Passing the testbench and observing the message:

Simulation succeeded


confirms that:
- Decode and ALU logic are correctly extended,
- Control and memory paths are intact,
- The processor executes all RV32I and RVX10 instructions correctly.



