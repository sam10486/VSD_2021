module forward(
input EXMEM_RegWrite,
input MEMWB_RegWrite,
input [4:0] EXMEM_rd_addr,
input [4:0] MEMWB_rd_addr,
input [4:0] IDEX_rs1_addr,
input [4:0] IDEX_rs2_addr,
output logic [1:0] forwardSrc1,
output logic [1:0] forwardSrc2
);


always@(*)begin
	if(EXMEM_RegWrite & (EXMEM_rd_addr != 5'd0) & (EXMEM_rd_addr == IDEX_rs1_addr))begin
		forwardSrc1 = 2'b01;
	end
	else if(MEMWB_RegWrite & (MEMWB_rd_addr != 5'd0) & (MEMWB_rd_addr == IDEX_rs1_addr))begin
		forwardSrc1 = 2'b10;
	end
	else begin
		forwardSrc1 = 2'b00;
	end
end

always@(*)begin
	if(EXMEM_RegWrite & (EXMEM_rd_addr != 5'd0) & (EXMEM_rd_addr == IDEX_rs2_addr))begin
		forwardSrc2 = 2'b01;
	end
	else if(MEMWB_RegWrite & (MEMWB_rd_addr != 5'd0) & (MEMWB_rd_addr == IDEX_rs2_addr))begin
		forwardSrc2 = 2'b10;
	end
	else begin
		forwardSrc2 = 2'b00;
	end
end

endmodule