module comparator(
    input A,
    input B,
    output o1,// for A>B
    output o2,//for A==B
    output o3//for A<B

);
 assign o1 = (A & ~B);
  assign o2 = ~(A ^ B) ;
  assign o3 = (~A & B) ;
endmodule