module sign_process (
    input [31:0] D_in,
    output logic sign,
    output logic [31:0] D_out
);
    logic [31:0] D_in_inv;
    assign D_in_inv = (D_in - 32'd1) ^ 32'hffff_ffff;
    assign sign = D_in[31];
    assign D_out = (D_in[31] == 1'b0) ? D_in : D_in_inv;
endmodule