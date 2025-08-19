module vending_mealy(
    input wire clk,
    input wire rst,       // sync active-high reset
    input wire [1:0] coin, // 01=5, 10=10, 00=idle (ignore 11)
    output reg dispense,   // 1-cycle pulse when total >= 20
    output reg chg5        // 1-cycle pulse when total=25
);

    parameter S0  = 3'b000,  // 0
              S5  = 3'b001,  // 5
              S10 = 3'b010,  // 10
              S15 = 3'b011,  // 15
              S20 = 3'b100;  // 20 (dispense here)
        
    reg [2:0] state, next_state;
    wire coin5  = (coin == 2'b01);  // 5 coin
    wire coin10 = (coin == 2'b10);  // 10 coin
    always @(*) begin
        next_state = state;
        dispense = 1'b0;
        chg5 = 1'b0;

        case(state)
            S0: begin
                if (coin5)       next_state = S5;
                else if (coin10) next_state = S10;
            end
            S5: begin
                if (coin5)       next_state = S10;
                else if (coin10) next_state = S15;
            end
            S10: begin
                if (coin5)       next_state = S15;
                else if (coin10) next_state = S20;
            end
            S15: begin
                if (coin5)       next_state = S20;
                else if (coin10) begin
                    next_state = S0;
                    dispense = 1'b1;  
                    chg5 = 1'b1;
                end
            end
            S20: begin
                next_state = S0;
                dispense = 1'b1;  
            end
        endcase
    end


    always @(posedge clk) begin
        if (rst) state <= S0;
        else state <= next_state;
    end

endmodule