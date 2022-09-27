`include "define.sv"

module Forwarding (
    input [4:0] EX_rs1, EX_rs2,
    input [4:0] MEM_rd, WB_rd,
    input WB_RegWrite, MEM_RegWrite,
    output logic [1:0] FA, FB
);

always_comb begin
    if (MEM_RegWrite & (MEM_rd != 5'd0) & (MEM_rd == EX_rs1)) begin
        FA = 2'b10;
    end else if (WB_RegWrite & (WB_rd != 5'd0) & (WB_rd == EX_rs1)) begin
        FA = 2'b01;
    end else begin
        FA = 2'b00;
    end

    if (MEM_RegWrite & (MEM_rd != 5'd0) & (MEM_rd == EX_rs2)) begin
        FB = 2'b10;
    end else if (WB_RegWrite & (WB_rd != 5'd0) & (WB_rd == EX_rs2)) begin
        FB = 2'b01;
    end else begin
        FB = 2'b00;
    end
end


endmodule