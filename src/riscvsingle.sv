// =====================================================
// RISC-V Single-Cycle Processor with RVX10 Extensions
// =====================================================
// Supports custom opcode 0001011 (CUSTOM-0)
// Implements ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS
// =====================================================
// ANSHIKA RAJ YADAV - 230102111
module testbench();
  logic clk, reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  // reset
  initial begin
    reset <= 1; #22; reset <= 0;
  end

  // clock
  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  // simulation monitor
  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 && WriteData === 25) begin
        $display("Simulation succeeded");
        $finish;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed: wrote %0d to addr %0d", WriteData, DataAdr);
        $finish;
      end
    end
  end
endmodule


module top(input logic clk, reset,
           output logic [31:0] WriteData, DataAdr,
           output logic MemWrite);

  logic [31:0] PC, Instr, ReadData;
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(input  logic clk, reset,
                   output logic [31:0] PC,
                   input  logic [31:0] Instr,
                   output logic MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input  logic [31:0] ReadData);

  logic       ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  logic [3:0] ALUControl;  // extended width for RVX10

  controller c(Instr[6:0], Instr[14:12], Instr[31:25],
               Zero, ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump, ImmSrc, ALUControl);

  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite, ImmSrc, ALUControl,
              Zero, PC, Instr, ALUResult, WriteData, ReadData);
endmodule


module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic [6:0] funct7,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [3:0] ALUControl);

  logic [1:0] ALUOp;
  logic Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op, funct3, funct7, ALUOp, ALUControl);

  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;
  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_10_0; // RVX10 custom ops
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x;
    endcase
endmodule


module aludec(input  logic [6:0] op,
              input  logic [2:0] funct3,
              input  logic [6:0] funct7,
              input  logic [1:0] ALUOp,
              output logic [3:0] ALUControl);

  localparam OPCODE_CUSTOM = 7'b0001011;

  always_comb begin
    if (op == OPCODE_CUSTOM) begin
      // RVX10 instruction decode
      unique case ({funct7, funct3})
        10'b0000000000: ALUControl = 4'b1000; // ANDN
        10'b0000000001: ALUControl = 4'b1001; // ORN
        10'b0000000010: ALUControl = 4'b1010; // XNOR
        10'b0000001000: ALUControl = 4'b1011; // MIN
        10'b0000001001: ALUControl = 4'b1100; // MAX
        10'b0000001010: ALUControl = 4'b1101; // MINU
        10'b0000001011: ALUControl = 4'b1110; // MAXU
        10'b0000010000: ALUControl = 4'b1111; // ROL
        10'b0000010001: ALUControl = 4'b0000; // ROR
        10'b0000011000: ALUControl = 4'b0001; // ABS
        default:         ALUControl = 4'b1111;
      endcase
    end else begin
      // Regular ALU
      case(ALUOp)
        2'b00: ALUControl = 4'b0010; // add
        2'b01: ALUControl = 4'b0110; // sub
        default: case(funct3)
          3'b000: if (funct7[5]) ALUControl = 4'b0110; else ALUControl = 4'b0010; // sub/add
          3'b010: ALUControl = 4'b0111; // slt
          3'b110: ALUControl = 4'b0001; // or
          3'b111: ALUControl = 4'b0000; // and
          default: ALUControl = 4'b0010;
        endcase
      endcase
    end
  end
endmodule

module datapath(input  logic        clk, reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [3:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  flopr #(32) pcreg(clk, reset, PCNext, PC); 
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 
  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                 Instr[11:7], Result, SrcA, WriteData);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule


module alu(input  logic [31:0] a, b,
           input  logic [3:0]  alucontrol,
           output logic [31:0] result,
           output logic zero);

  wire signed [31:0] s1 = a;
  wire signed [31:0] s2 = b;
  logic [4:0] sh = b[4:0];

  always_comb begin
    case (alucontrol)
      4'b0010: result = a + b; // add
      4'b0110: result = a - b; // sub
      4'b0000: result = a & b; // and
      4'b0001: result = a | b; // or
      4'b0111: result = (s1 < s2) ? 1 : 0; // slt
      // RVX10 custom
      4'b1000: result = a & ~b; // ANDN
      4'b1001: result = a | ~b; // ORN
      4'b1010: result = ~(a ^ b); // XNOR
      4'b1011: result = (s1 < s2) ? a : b; // MIN
      4'b1100: result = (s1 > s2) ? a : b; // MAX
      4'b1101: result = (a < b) ? a : b;   // MINU
      4'b1110: result = (a > b) ? a : b;   // MAXU
      4'b1111: result = (sh == 0) ? a : ((a << sh) | (a >> (32 - sh))); // ROL
      4'b0000: result = (sh == 0) ? a : ((a >> sh) | (a << (32 - sh))); // ROR
      4'b0001: result = (s1 >= 0) ? a : (0 - a); // ABS
      default: result = 32'b0;
    endcase
  end

  assign zero = (result == 32'b0);
endmodule


module regfile(input logic clk, we3, 
               input logic [4:0] a1, a2, a3, 
               input logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);
  logic [31:0] rf[31:0];
  always_ff @(posedge clk)
    if (we3 && a3 != 0) rf[a3] <= wd3;
  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input [31:0] a,b, output [31:0] y);
  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
  always_comb
    case(immsrc) 
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};  
      2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
      2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
      2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
      default: immext = 32'bx;
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
  (input logic clk, reset,
   input logic [WIDTH-1:0] d, 
   output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] d0,d1, input logic s, output logic [WIDTH-1:0] y);
  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] d0,d1,d2,
   input logic [1:0] s, output logic [WIDTH-1:0] y);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module imem(input logic [31:0] a, output logic [31:0] rd);
  logic [31:0] RAM[63:0];
  initial $readmemh("riscvtest.txt",RAM);
  assign rd = RAM[a[31:2]];
endmodule

module dmem(input logic clk,we,input logic [31:0] a,wd, output logic [31:0] rd);
  logic [31:0] RAM[63:0];
  assign rd = RAM[a[31:2]];
  always_ff @(posedge clk) if (we) RAM[a[31:2]] <= wd;
endmodule
