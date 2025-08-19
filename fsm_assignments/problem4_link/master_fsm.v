module master_fsm(
    input wire clk,
    input wire rst,
    input wire ack,
    output reg req,
    output reg [7:0] data,
    output reg done
);

    
    parameter [1:0] IDLE = 2'b00,
                   SEND = 2'b01,
                   WAIT_ACK = 2'b10,
                   COMPLETE = 2'b11;
    
    reg [1:0] state, next_state;
    reg [1:0] byte_count;
    reg [7:0] data_values [0:3]; 
    
    
    initial begin
        data_values[0] = 8'hA5;
        data_values[1] = 8'h3C;
        data_values[2] = 8'h7E;
        data_values[3] = 8'hD9;
    end
    
    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: next_state = SEND;
            SEND: next_state = WAIT_ACK;
            WAIT_ACK: begin
                if (ack) next_state = (byte_count == 3) ? COMPLETE : SEND;
            end
            COMPLETE: next_state = IDLE;
        endcase
    end
    
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            byte_count <= 0;
            req <= 0;
            done <= 0;
            data <= 0;
        end
        else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    byte_count <= 0;
                    done <= 0;
                end
                SEND: begin
                    req <= 1;
                    data <= data_values[byte_count];
                end
                WAIT_ACK: begin
                    if (ack) begin
                        req <= 0;
                        byte_count <= byte_count + 1;
                    end
                end
                COMPLETE: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule