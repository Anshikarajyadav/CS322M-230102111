
module tb_traffic_light;
    reg clk, rst;
    wire tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;
   
    traffic_light dut(
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .ns_g(ns_g),
        .ns_y(ns_y),
        .ns_r(ns_r),
        .ew_g(ew_g),
        .ew_y(ew_y),
        .ew_r(ew_r)
    );
    
    // Clock generation (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    
    reg [4:0] tick_counter;
    assign tick = (tick_counter == 19);
    always @(posedge clk) begin
        if (rst) tick_counter <= 0;
        else tick_counter <= (tick_counter == 19) ? 0 : tick_counter + 1;
    end
    
 
    initial begin
        
        rst = 1;
        #20 rst = 0;
        
        
        #(56*20*10);
        
        $finish;
    end
    
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);
    end
    
   
    always @(posedge clk) begin
        if (tick) begin
            $display("Time=%0t: State=%b, NS=%b%b%b, EW=%b%b%b",
                     $time, dut.state,
                     ns_g, ns_y, ns_r,
                     ew_g, ew_y, ew_r);
        end
    end
endmodule