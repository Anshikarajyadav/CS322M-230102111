`timescale 1ns/1ps
module tb_seq_detect_mealy;
  reg clk=0, rst=1, din=0;
  wire y;

  seq_detect_mealy dut(.clk(clk), .rst(rst), .din(din), .y(y));

  always #5 clk = ~clk;  // 10ns period

 
  reg [10:0] stream = 11'b11011011101;
  integer i;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_seq_detect_mealy);

   
    repeat (3) @(posedge clk);
    rst = 0;

    
    for (i = 10; i >= 0; i=i-1) begin
      din = stream[i];
      @(posedge clk);
      #1;
      if (y) $display("t=%0t ns: DETECT at index %0d", $time, 10-i);
    end

    repeat (5) @(posedge clk);
    $finish;
  end
endmodule
