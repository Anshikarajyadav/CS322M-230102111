`timescale 1ns/1ns
module tb_equality_comp;
reg [3:0] A , B;
wire out;
equality_comp uut(
    .A(A),
    .B(B),
    .is_equal(out)
);
 initial begin
    $dumpfile("equality_comp.vcd");
    $dumpvars(0 , tb_equality_comp);

 end
 initial begin
    $display(" A  B | is_equal");
    $monitor("%d %d | %b" , A , B , out);
    A=4'd0 ; B=4'd0;
    #10 A=4'd1; B=4'd0;
    #10 A=4'd4 ; B=4'd14;
    #10 A=4'd13  ; B=4'd13;
    #10;
    $finish;
 end

endmodule