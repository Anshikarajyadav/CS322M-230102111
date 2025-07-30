module equality_comp(
    input [3:0] A, B,
    output is_equal
);
  assign is_equal = &(~(A^B)); 
endmodule