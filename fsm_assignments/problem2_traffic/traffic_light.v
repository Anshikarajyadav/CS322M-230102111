module traffic_light(
    input wire clk,
    input wire rst,  // sync active-high
    input wire tick, // 1-cycle per-second pulse
    output wire ns_g, ns_y, ns_r,
    output wire ew_g, ew_y, ew_r
);


    parameter [1:0] NS_GREEN = 2'b00,
                   NS_YELLOW = 2'b01,
                   EW_GREEN = 2'b10,
                   EW_YELLOW = 2'b11;
    
    reg [1:0] state, next_state;
    reg [2:0] tick_counter;
    
    always @(*) begin
        next_state = state;
        case (state)
            NS_GREEN:  if (tick_counter == 4) next_state = NS_YELLOW;
            NS_YELLOW: if (tick_counter == 1) next_state = EW_GREEN;
            EW_GREEN:  if (tick_counter == 4) next_state = EW_YELLOW;
            EW_YELLOW: if (tick_counter == 1) next_state = NS_GREEN;
        endcase
    end
    
    
    always @(posedge clk) begin
        if (rst) begin
            state <= NS_GREEN;
            tick_counter <= 0;
        end
        else if (tick) begin
            state <= next_state;
            if (next_state != state)
                tick_counter <= 0;
            else
                tick_counter <= tick_counter + 1;
        end
    end
    
    assign ns_g = (state == NS_GREEN);
    assign ns_y = (state == NS_YELLOW);
    assign ns_r = ~(ns_g | ns_y);
    assign ew_g = (state == EW_GREEN);
    assign ew_y = (state == EW_YELLOW);
    assign ew_r = ~(ew_g | ew_y);

endmodule
module tick_prescaler #(
    parameter integer CLK_FREQ_HZ = 50_000_000, 
    parameter integer TICK_HZ = 1              
)(
    input wire clk,  
    input wire rst,  
    output wire tick // 1-cycle pulse at TICK_HZ
);

    localparam integer MAX_COUNT = CLK_FREQ_HZ / TICK_HZ - 1;
    reg [$clog2(MAX_COUNT)-1:0] counter;
    
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
        end
        else if (counter == MAX_COUNT) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
    
    assign tick = (counter == MAX_COUNT);

endmodule