`include "../include/AXI_define.svh"
`include "../include/def.svh"
`include "CPU.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"

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

logic	[2:0]					cs_m0,cs_m1,ns_m0,ns_m1;
logic							IM_read,DM_read,DM_write;
logic	[31:0]					IM_Data_out,DM_Data_out;
logic	[31:0]					DM_Data_in;
logic	[31:0]					IM_addr,DM_addr;	
logic							IM_cs,IM_oe,DM_cs,DM_oe;
logic	[3:0]					IM_web,DM_web;
logic							CPU_READY;

//cache
logic							I_wait,D_wait;
logic							I_req,D_req;
logic							IM_wait,DM_wait;
logic 	[31:0]					RDATA_M0_buf;
logic 	[31:0]					RDATA_M1_buf;
logic 	[`DATA_BITS-1:0] 		D_addr, I_addr;
logic 							D_write, I_write;
logic 	[`DATA_BITS-1:0] 		D_in, I_in;
logic 	[`CACHE_TYPE_BITS-1:0] 	D_type, I_type;
logic							core_req_I,core_req_D;
logic 	[2:0]					DM_type;

logic	[31:0]					IM_Data_out_buffer;
logic	[31:0]					IM_addr_buffer;
logic	[31:0]					IM_addr_cache;
logic	[31:0]					DM_Data_out_buffer;



// IM cache
assign core_req_I = (IM_read) ? 1'b1 : 1'b0;
assign core_req_D = (DM_read || DM_write) ? 1'b1 : 1'b0;
//assign I_wait = (cs_m0 == `IDLE)? 1'b0 : 1'b1;
//assign D_wait = (cs_m1 == `IDLE)? 1'b0 : 1'b1;
/*
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		core_req_I <= 1'b0; 
	end
	else begin
		if(CPU_READY && IM_read) begin
			core_req_I <= 1'b1; 
		end
		else begin
			core_req_I <= 1'b0; 
		end
	end
end
*/

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		I_wait <= 1'b1; 
	end
	else begin
		if(cs_m0 == `Buffer && ns_m0 == `IDLE) begin
			I_wait <= 1'b0;
		end
		else begin
			I_wait <= 1'b1;
		end
	end
end


always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		D_wait <= 1'b1; 
	end
	else begin
		if(((cs_m1 == `RData)||(cs_m1 == `WResp)) && ns_m1 == `IDLE) begin
			D_wait <= 1'b0;
		end
		else begin
			D_wait <= 1'b1;
		end
	end
end





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
			if(I_req && (~I_write))
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
	else if(IM_read && (cs_m0 == `RAddr)) begin
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
		ARADDR_M0	<= I_addr;
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
		RDATA_M0_buf <= 32'd0; 
	end
	else if(RREADY_M0 && RVALID_M0) begin
		RDATA_M0_buf <= RDATA_M0;
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
			if(D_req && (~D_write))
				ns_m1 = `RAddr;
			else if(D_req && D_write)
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
	else if((~D_write) && (D_req) && (cs_m1 == `IDLE)) begin
		ARVALID_M1	<= 1'b1;
	end
end

/*
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARADDR_M1	<= 32'd0;
	end
	else if(ARVALID_M1) begin
		ARADDR_M1	<= ARADDR_M1;
	end
	else begin
		ARADDR_M1	<= D_addr;
	end
end
*/

assign ARADDR_M1 = (ARVALID_M1) ? D_addr : 32'd0;

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
		RDATA_M1_buf <= 32'd0; 
	end
	else if(RREADY_M1 && RVALID_M1) begin
		RDATA_M1_buf <= RDATA_M1;
	end
end

//WRITE ADDRESS
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		AWVALID_M1	<= 1'b0;
	end
	else if((cs_m1 == `IDLE) && (D_write) && (D_req)) begin
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
		AWADDR_M1	<= D_addr;
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
		WDATA_M1  = D_in;
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
/*
always_comb begin
	if((cs_m0 == `IDLE) && (cs_m1 == `IDLE)) begin
		CPU_READY = 1'b1;
	end
	else begin
		CPU_READY = 1'b0;
	end
end
*/
assign CPU_READY = (~IM_wait && ~DM_wait) ? 1'b1:1'b0;


CPU CPU1 (
.clk(ACLK),
.rst(~ARESETn),
//.dick(big black dick),
.IM_data_out(IM_Data_out_buffer),
.DM_data_out(DM_Data_out_buffer),
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
.DM_WEB(DM_web),
.MEM_funct3(DM_type)
);

//for IM
L1C_inst L1CI ( 
.clk(ACLK),
.rst(!ARESETn),
//input
.core_addr(IM_addr_cache),
.core_req(core_req_I),
.core_write(1'b0),
.core_in(32'd0),
.core_type(`CACHE_WORD),

.I_out(RDATA_M0_buf),  //data from cpu wrapper
.I_wait(I_wait),
//output
.core_out(IM_Data_out),       //data to CPU
.core_wait(IM_wait),

.I_req(I_req),
.I_addr(I_addr),
.I_write(I_write),
.I_in(I_in),
.I_type(I_type)
);

//for DM
L1C_data L1CD (  
.clk(ACLK),
.rst(!ARESETn),
//input
.core_addr(DM_addr),
.core_req(core_req_D),
.core_write(DM_write),
.core_in(DM_Data_in),
.core_type(DM_type),

.D_out(RDATA_M1_buf),
.D_wait(D_wait),
//output
.core_out(DM_Data_out),
.core_wait(DM_wait),

.D_req(D_req),
.D_addr(D_addr),
.D_write(D_write),
.D_in(D_in),
.D_type(D_type)
);

//IM_data_out_buffer
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		IM_Data_out_buffer <= 32'd0;
	end
	else begin
		IM_Data_out_buffer <= IM_Data_out;
	end
end

//IM_addr_buffer
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		IM_addr_buffer <= 32'd0;
	end
	else if(CPU_READY) begin
		IM_addr_buffer <= IM_addr;
	end
end

assign IM_addr_cache = (CPU_READY) ? (IM_addr):(IM_addr_buffer);

//DM_Data_out_buffer
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		DM_Data_out_buffer <= 32'd0;
	end
	else begin
		if(DM_wait == 1'b1) begin
			DM_Data_out_buffer <= DM_Data_out;
		end
		else begin
			DM_Data_out_buffer <= DM_Data_out_buffer;
		end
	end
end

//DM_addr_buffer



endmodule
