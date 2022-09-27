`include "../include/AXI_define.svh"
`include "CPU.sv"

`define IDLE    3'b000
`define RAddr 	3'b001
`define RData 	3'b010
`define WAddr 	3'b011
`define WData  	3'b100
`define WResp  	3'b101
`define Buffer	3'b110

module CPU_wrapper(
	input ACLK,
	input ARESETn,

	//WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1,

	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0,
	
	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1
);

logic	[2:0]	cs_m0,cs_m1,ns_m0,ns_m1;
logic			IM_read,DM_read,DM_write;
logic	[31:0]	IM_Data_out,DM_Data_out;
logic	[31:0]	DM_Data_in;
logic	[31:0]	IM_addr,DM_addr;	
logic			IM_cs,IM_oe,DM_cs,DM_oe;
logic	[3:0]	IM_web,DM_web;
logic			CPU_READY;

//Master0 IM
assign IM_read 	= IM_cs && IM_oe;

//FSM m0
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cs_m0 <= 3'd0;
	end
	else begin 
		cs_m0 <= ns_m0;
	end
end

always_comb begin
	case(cs_m0)
		`IDLE: begin
			if(IM_read)
				ns_m0 = `RAddr;
			else
				ns_m0 = `IDLE;
		end
		`RAddr: begin
			if(ARVALID_M0 && ARREADY_M0)
				ns_m0 = `RData;
			else
				ns_m0 = `RAddr;
		end
		`RData: begin
			if(RLAST_M0 && RREADY_M0 && RVALID_M0)
				ns_m0 = `Buffer;
			else
				ns_m0 = `RData;
		end
		`Buffer: begin
			ns_m0 = `IDLE;
		end
		default: begin
				ns_m0 = `IDLE;
		end
	endcase
end

//READ ADDRESS
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARVALID_M0	<= 1'b0;
	end
	else if(ARREADY_M0 && ARVALID_M0) begin
		ARVALID_M0	<= 1'b0;
	end
	else if(IM_read && (cs_m0 == `IDLE)) begin
		ARVALID_M0	<= 1'b1;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARADDR_M0	<= 32'd0;
	end
	else if(ARVALID_M0) begin
		ARADDR_M0	<= ARADDR_M0;
	end
	else begin
		ARADDR_M0	<= IM_addr;
	end
end

always_comb begin
	if(ARVALID_M0) begin
		ARID_M0		= 4'd1;
		ARLEN_M0	= 4'd0;
		ARSIZE_M0	= 3'd2;
		ARBURST_M0	= 2'd1;
	end
	else begin
		ARID_M0		= 4'd0;
		ARLEN_M0	= 4'd0;
		ARSIZE_M0	= 3'd0;
		ARBURST_M0	= 2'd0;
	end
end

//READ DATA
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		RREADY_M0	<= 1'b0;
	end
	else if(RREADY_M0) begin
		RREADY_M0	<= 1'b0;
	end
	else if(RVALID_M0 && ~RREADY_M0) begin
		RREADY_M0	<= 1'b1;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		IM_Data_out	<= 32'd0; 
	end
	else if(RREADY_M0 && RVALID_M0) begin
		IM_Data_out <= RDATA_M0;
	end
end

///////////////////////////////////////////////////////////////////////////////

//Master1 DM
assign DM_read 	= DM_cs && DM_oe;
assign DM_write	= DM_cs && (DM_web!=4'b1111);

//FSM m1
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cs_m1 <= 3'd0;
	end
	else begin 
		cs_m1 <= ns_m1;
	end
end

always_comb begin
	case(cs_m1)
		`IDLE: begin
			if(DM_read)
				ns_m1 = `RAddr;
			else if(DM_write)
				ns_m1 = `WAddr;
			else
				ns_m1 = `IDLE;
		end
		`RAddr: begin
			if(ARVALID_M1 && ARREADY_M1)
				ns_m1 = `RData;
			else
				ns_m1 = `RAddr;
		end
		`RData: begin
			if(RLAST_M1 && RREADY_M1 && RVALID_M1)
				ns_m1 = `IDLE;
			else
				ns_m1 = `RData;
		end
		`WAddr: begin
			if(AWVALID_M1 && AWREADY_M1)
				ns_m1 = `WData;
			else
				ns_m1 = `WAddr;
		end
		`WData: begin
			if(WREADY_M1 && WVALID_M1 && WLAST_M1)
				ns_m1 = `WResp;
			else
				ns_m1 = `WData;
		end
		`WResp: begin
			if(BVALID_M1 && BREADY_M1)
				ns_m1 = `IDLE;
			else
				ns_m1 = `WResp;
		end
		default: begin
				ns_m1 = `IDLE;
		end
	endcase
end

//READ ADDRESS

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARVALID_M1	<= 1'b0;
	end
	else if(ARREADY_M1 && ARVALID_M1) begin
		ARVALID_M1	<= 1'b0;
	end
	else if(DM_read && (cs_m1 == `IDLE)) begin
		ARVALID_M1	<= 1'b1;
	end
end

/*
always_comb begin
	if(cs_m1 == `RAddr) begin
		ARVALID_M1 = 1'b1;
	end
	else begin
		ARVALID_M1 = 1'b0;
	end
end
*/

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARADDR_M1	<= 32'd0;
	end
	else if(ARVALID_M1) begin
		ARADDR_M1	<= ARADDR_M1;
	end
	else begin
		ARADDR_M1	<= DM_addr;
	end
end

always_comb begin
	if(ARVALID_M1) begin
		ARID_M1		= 4'd1;
		ARLEN_M1	= 4'd0;
		ARSIZE_M1	= 3'd2;
		ARBURST_M1	= 2'd1;
	end
	else begin
		ARID_M1		= 4'd0;
		ARLEN_M1	= 4'd0;
		ARSIZE_M1	= 3'd0;
		ARBURST_M1	= 2'd0;
	end
end

//READ DATA
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		RREADY_M1	<= 1'b0;
	end
	else if(RREADY_M1) begin
		RREADY_M1	<= 1'b0;
	end
	else if(RVALID_M1 && ~RREADY_M1) begin
		RREADY_M1	<= 1'b1;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		DM_Data_out	<= 32'd0; 
	end
	else if(RREADY_M1 && RVALID_M1) begin
		DM_Data_out <= RDATA_M1;
	end
end

//WRITE ADDRESS
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		AWVALID_M1	<= 1'b0;
	end
	else if((cs_m1 == `IDLE) && DM_write) begin
		AWVALID_M1	<= 1'b1;
	end
	else if(AWVALID_M1 && AWREADY_M1) begin
		AWVALID_M1	<= 1'b0;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		AWADDR_M1	<= 32'd0;
	end
	else if(AWVALID_M1) begin
		AWADDR_M1	<= AWADDR_M1;
	end
	else begin
		AWADDR_M1	<= DM_addr;
	end
end

always_comb begin
	if(AWVALID_M1) begin
		AWID_M1		= 4'd1;
		AWLEN_M1	= 4'd0;
		AWSIZE_M1	= 3'd2;
		AWBURST_M1	= 2'd1;
	end
	else begin
		AWID_M1		= 4'd0;
		AWLEN_M1	= 4'd0;
		AWSIZE_M1	= 3'd0;
		AWBURST_M1	= 2'd0;
	end
end

//WRITE DATA
always_comb begin
	if(cs_m1 == `WData) begin
		WVALID_M1 = 1'b1;
		WDATA_M1  = DM_Data_in;
		WSTRB_M1  = DM_web;
		WLAST_M1  = 1'b1;		
	end
	else begin
		WVALID_M1 = 1'b0;
		WDATA_M1  = 32'd0; 
		WSTRB_M1  = 4'b1111;
		WLAST_M1  = 1'b0;	
	end
end

//WRITE RESPONSE
always_ff @(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		BREADY_M1 <= 1'b0;
	end
	else if(BVALID_M1 && ~BREADY_M1) begin
		BREADY_M1 <= 1'b1;
	end
	else if(BREADY_M1) begin
		BREADY_M1 <= 1'b0;
	end		
end

//CPU_READY
always_comb begin
	if((cs_m0 == `IDLE) && (cs_m1 == `IDLE)) begin
		CPU_READY = 1'b1;
	end
	else begin
		CPU_READY = 1'b0;
	end
end


CPU CPU1 (
.clk(ACLK),
.rst(~ARESETn),

.IM_data_out(IM_Data_out),
.DM_data_out(DM_Data_out),
.CPU_READY(CPU_READY),
.cs_m0(cs_m0),
.cs_m1(cs_m1),
.ns_m0(ns_m0),
.ns_m1(ns_m1),

.IM_addr(IM_addr),
.DM_addr(DM_addr),
.DM_data_in(DM_Data_in),
.IM_CS(IM_cs),
.IM_OE(IM_oe),
.DM_CS(DM_cs),
.DM_OE(DM_oe),
.IM_WEB(IM_web),
.DM_WEB(DM_web)
);


endmodule
