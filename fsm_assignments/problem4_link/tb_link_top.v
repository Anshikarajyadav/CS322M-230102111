module tb_link_top;
    reg clk, rst;
    wire done;
    
    link_top dut(.clk(clk), .rst(rst), .done(done));
    
    // Clock generation (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    
    initial begin
        rst = 1;
        #20 rst = 0;
    end
    
   
    initial begin
        wait(done == 1);
        #20 $finish;
    end
    
 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_link_top);
    end
    

    always @(posedge clk) begin
        $display("Time=%0t: req=%b, ack=%b, data=%h, done=%b",
                $time, dut.master.req, dut.slave.ack, dut.master.data, done);
    end

endmodule
