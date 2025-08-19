module slave_fsm(
    input wire clk,
    input wire rst,
    input wire req,
    input wire [7:0] data,
    output reg ack
);


    parameter [1:0] IDLE = 2'b00,
                   LATCH = 2'b01,
                   HOLD_ACK = 2'b10,
                   WAIT_REQ = 2'b11;
    
    reg [1:0] state, next_state;
    reg [1:0] hold_counter;
    reg [7:0] latched_data;
    
    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (req) next_state = LATCH;
            LATCH: next_state = HOLD_ACK;
            HOLD_ACK: begin
                if (hold_counter == 1) next_state = WAIT_REQ;
            end
            WAIT_REQ: if (~req) next_state = IDLE;
        endcase
    end
    

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ack <= 0;
            hold_counter <= 0;
            latched_data <= 0;
        end
        else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    ack <= 0;
                    hold_counter <= 0;
                end
                LATCH: begin
                    latched_data <= data;
                    ack <= 1;
                end
                HOLD_ACK: begin
                    hold_counter <= hold_counter + 1;
                end
                WAIT_REQ: begin
                    ack <= 0;
                    hold_counter <= 0;
                end
            endcase
        end
    end

endmodule
