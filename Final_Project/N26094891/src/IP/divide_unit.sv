module divide_unit (
    input [31:0] A,
    input [31:0] B,
    output logic C,
    output logic [31:0] D
);

assign C = (($unsigned(A) >= $unsigned(B)) && B != 32'd0) ? 1'b1 : 1'b0;
assign D = (($unsigned(A) >= $unsigned(B)) && B != 32'd0) ? (A - B) : A;
    
endmodule