module link_top(
    input wire clk,
    input wire rst,
    output wire done
);

    wire req, ack;
    wire [7:0] data;
    
    master_fsm master (
        .clk(clk),
        .rst(rst),
        .ack(ack),
        .req(req),
        .data(data),
        .done(done)
    );
    
    slave_fsm slave (
        .clk(clk),
        .rst(rst),
        .req(req),
        .data(data),
        .ack(ack)
    );

endmodule
