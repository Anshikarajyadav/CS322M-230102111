# RVX10 Instruction Encodings
CS322M — Single-Cycle RISC-V Processor (RVX10 Extension)  
Author: **Anshika Yadav (IIT Guwahati)**  
Target ISA: **RV32I + Custom-0 Opcode (0x0B)**

---

## 1. Overview

This document defines the binary instruction formats for all **10 custom RVX10 operations** implemented in the single-cycle RISC-V CPU.

All instructions follow the **R-type format** and use the **Custom-0 opcode**:

| Field | Bits     | Description |
|:------|:----------|:-------------|
| `funct7` | [31:25] | Function sub-encoding |
| `rs2` | [24:20] | Source register 2 |
| `rs1` | [19:15] | Source register 1 |
| `funct3` | [14:12] | Function selector |
| `rd` | [11:7] | Destination register |
| `opcode` | [6:0] | `0001011` (CUSTOM-0) |

---

## 2. RVX10 Opcode Summary

| Instruction | Mnemonic | `funct7` | `funct3` | Description | Operation |
|:-------------|:----------|:----------|:----------|:--------------|:------------|
| 1 | **ANDN** | 0000000 | 000 | Bitwise AND-NOT | `rd = rs1 & ~rs2` |
| 2 | **ORN** | 0000000 | 001 | Bitwise OR-NOT | `rd = rs1 \| ~rs2` |
| 3 | **XNOR** | 0000000 | 010 | Bitwise XNOR | `rd = ~(rs1 ^ rs2)` |
| 4 | **MIN** | 0000001 | 000 | Signed minimum | `rd = (rs1 < rs2) ? rs1 : rs2` |
| 5 | **MAX** | 0000001 | 001 | Signed maximum | `rd = (rs1 > rs2) ? rs1 : rs2` |
| 6 | **MINU** | 0000001 | 010 | Unsigned minimum | `rd = (rs1 < rs2) ? rs1 : rs2` |
| 7 | **MAXU** | 0000001 | 011 | Unsigned maximum | `rd = (rs1 > rs2) ? rs1 : rs2` |
| 8 | **ROL** | 0000010 | 000 | Rotate-left | `rd = (rs1 << (rs2[4:0])) \| (rs1 >> (32 - rs2[4:0]))` |
| 9 | **ROR** | 0000010 | 001 | Rotate-right | `rd = (rs1 >> (rs2[4:0])) \| (rs1 << (32 - rs2[4:0]))` |
| 10 | **ABS** | 0000011 | 000 | Absolute value | `rd = (rs1 < 0) ? -rs1 : rs1` |

---

## 3. Encoding Example

### Example 1 — `ANDN x5, x6, x7`

| Field | Bits | Value |
|:------|:-----|:------|
| `funct7` | [31:25] | `0000000` |
| `rs2` | [24:20] | `00111` |
| `rs1` | [19:15] | `00110` |
| `funct3` | [14:12] | `000` |
| `rd` | [11:7] | `00101` |
| `opcode` | [6:0] | `0001011` |

**Binary:**  
`0000000_00111_00110_000_00101_0001011`  
**Hex:** `0x00E3028B`

→ This instruction computes `x5 = x6 & ~x7`.

---

### Example 2 — `MAXU x10, x4, x3`

| Field | Bits | Value |
|:------|:-----|:------|
| `funct7` | [31:25] | `0000001` |
| `rs2` | [24:20] | `00011` |
| `rs1` | [19:15] | `00100` |
| `funct3` | [14:12] | `011` |
| `rd` | [11:7] | `01010` |
| `opcode` | [6:0] | `0001011` |

**Binary:**  
`0000001_00011_00100_011_01010_0001011`  
**Hex:** `0x0232230B`

→ This instruction computes `x10 = maxu(x4, x3)`.

---

### Example 3 — `ABS x8, x9`

(Single-operand pseudo-R instruction; `rs2` = `x0`)

| Field | Bits | Value |
|:------|:-----|:------|
| `funct7` | [31:25] | `0000011` |
| `rs2` | [24:20] | `00000` |
| `rs1` | [19:15] | `01001` |
| `funct3` | [14:12] | `000` |
| `rd` | [11:7] | `01000` |
| `opcode` | [6:0] | `0001011` |

**Binary:**  
`0000011_00000_01001_000_01000_0001011`  
**Hex:** `0x0604828B`

→ This computes `x8 = abs(x9)`.

---

## 4. Custom Opcode Allocation

| Range | Name | Description |
|:------|:------|:-------------|
| `0001011` | CUSTOM-0 | Used for RVX10 arithmetic/logical extensions |
| `0101011` | CUSTOM-1 | Reserved for future expansion |
| `1011011` | CUSTOM-2 | Reserved |
| `1111011` | CUSTOM-3 | Reserved |

---

## 5. Integration Notes

- Implemented in `aludec` using `if (op == 7'b0001011) case ({funct7, funct3}) ...`
- `alu` extended with new `case (alucontrol)` operations.
- The remaining datapath/control logic is unchanged.

---


