module seq_detect_mealy(
  input  wire clk,
  input  wire rst,   // sync active-high
  input  wire din,   // serial input bit per clock
  output wire y      // 1-cycle pulse when ...1101 seen
);

  
  parameter s0 = 2'b00,
            s1 = 2'b01,
            s2 = 2'b10,
            s3 = 2'b11;

  reg [1:0] state, next_state;

  
  always @(*) begin
    case (state)
      s0: next_state = din ? s1 : s0;
      s1: next_state = din ? s2 : s0;
      s2: next_state = din ? s2 : s3;
      s3: next_state = din ? s1 : s0;
      default: next_state = s0;
    endcase
  end

  
  always @(posedge clk) begin
    if (rst)
      state <= s0;
    else
      state <= next_state;
  end

  
  assign y = (state == s3) && din;

endmodule
