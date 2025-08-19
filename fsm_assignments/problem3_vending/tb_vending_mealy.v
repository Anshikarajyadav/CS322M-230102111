module tb_vending_mealy;
    reg clk, rst;
    reg [1:0] coin;
    wire dispense, chg5;

    vending_mealy dut (.*);

    // Clock (100MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1;
        coin = 0;
        #20 rst = 0;

    
        #10 coin = 2'b01; // 5
        #10 coin = 2'b01; // 5
        #10 coin = 2'b10; // 10 (total=20)
        #10 coin = 0;

        #20 coin = 2'b10; 
        #10 coin = 2'b10; 
        #10 coin = 0;

    
        #20 coin = 2'b01; // 5
        #10 coin = 2'b10; // 10
        #10 coin = 2'b10; // 10 (total=25)
        #10 coin = 0;

        #20 $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);
       
    end
endmodule