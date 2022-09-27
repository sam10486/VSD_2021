module hazard(
input IDEX_MemRead,
input [4:0] IDEX_rd_addr,
input [4:0] IFID_rs1_addr,
input [4:0] IFID_rs2_addr,
output logic stall1
);

always@(*)begin
	if(IDEX_MemRead)begin
		stall1 = ((IDEX_rd_addr == IFID_rs1_addr) || (IDEX_rd_addr == IFID_rs2_addr)) ? 1'b1 : 1'b0;
		//stall1 = 1'b0;
	end
	else begin
		stall1 = 1'b0;
	end
end

endmodule
