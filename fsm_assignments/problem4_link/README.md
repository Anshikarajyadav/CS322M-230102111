# Problem 4: Master-Slave Handshake System

## Description
This system implements a 4-phase handshake protocol between a Master and Slave FSM for transferring 4 bytes of data over an 8-bit bus.

## Specifications
- Master initiates transfer by asserting req and driving data
- Slave latches data when req is high and asserts ack for 2 cycles
- Master drops req when ack is detected
- Slave drops ack when req is low
- Process repeats for 4 bytes
- Master asserts done for 1 cycle after completing all transfers

## Files
1. `master_fsm.v` - Master FSM implementation
2. `slave_fsm.v` - Slave FSM implementation
3. `link_top.v` - Top-level module connecting Master and Slave
4. `tb_link_top.v` - Testbench for verification

## How to Run
1. Compile & simulate:
   ```bash
   iverilog -o sim_p4 tb_link_top.v link_top.v master_fsm.v slave_fsm.v
   vvp sim_p4
   gtkwave dump.vcd
   Open dump.vcd in GTKWave to verify timing.
   
## Expected Behavior
- 4 complete handshake sequences (req/ack/data)
- done signal asserted after 4th transfer
- Each ack pulse lasts exactly 2 clock cycles
- Data values transferred: A5, 3C, 7E, D9 (hex)

## Verification
The testbench automatically checks for:
- Proper handshake sequencing
- Correct data transfer
- Proper done signal assertion
- Simulation ends after done is asserted