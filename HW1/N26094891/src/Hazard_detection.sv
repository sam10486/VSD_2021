`include "define.sv"

module Hazard_detection (
    input EX_MemRead, MEM_MemRead,
    input [4:0] ID_rs1, ID_rs2, //address
    input [4:0] EX_rd, MEM_rd,
	input clk, rst,
    output logic stall
);

logic stall_tmp;

always_comb begin
    // ((EX_MemRead && ((EX_rd == ID_rs1) | (EX_rd == ID_rs2))) | (MEM_MemRead && ((MEM_rd == ID_rs1) | (MEM_rd == ID_rs2)))) begin
	if (MEM_MemRead && ~stall_tmp) begin
		stall = 1'd1;
	end else if(stall_tmp) begin
		stall = 1'd0;
    end else begin
        stall = 1'd0;
    end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		stall_tmp <= 1'd0;
	end else if(stall && ~stall_tmp) begin
		stall_tmp <= 1'd1;
	end else begin
		stall_tmp <= 1'd0;
	end
end

endmodule