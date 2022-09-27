`include "IP/IP_top.sv"

`define IDLE    3'b000
`define RAddr 	3'b001
`define RData 	3'b010
`define WAddr 	3'b011
`define WData  	3'b100
`define WResp  	3'b101
`define Buffer	3'b110

module S_IP_Wrapper(
	input ACLK,
	input ARESETn,
	
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
	
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY
);

logic	[2:0]					cs,ns;
logic	[31:0]					ARADDR_buf,AWADDR_buf;
logic 	[`AXI_IDS_BITS-1:0] 	ARID_buf,AWID_buf;

logic 	[1:0]  					IP_inst;
logic 	[9:0]  					IP_sr0_addr_in;
logic 	[31:0] 					IP_sr0_data_in;
logic 							IP_sr0_we;
logic 							IP_sr1_oe;
logic 							IP_sr1_oe_D1;
logic 	[9:0]  					IP_sr1_addr_in;
logic 	[31:0] 					IP_sr1_data_out;


//FSM
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cs <= `IDLE;
	end
	else begin
		cs <= ns;
	end
end

always_comb begin
	case(cs)
		`IDLE: begin
			if(ARVALID)
				ns = `RAddr;
			else if(AWVALID)
				ns = `WAddr;
			else
				ns = `IDLE;
		end
		`RAddr: begin
			if(ARVALID && ARREADY)
				ns = `RData;
			else
				ns = `RAddr;
		end
		`RData: begin
			if(RLAST && RREADY && RVALID)
				ns = `IDLE;
			else
				ns = `RData;
		end
		`WAddr: begin
			if(AWVALID && AWREADY)
				ns = `WData;
			else
				ns = `WAddr;
		end
		`WData: begin
			if(WVALID && WREADY && WLAST)
				ns = `WResp;
			else
				ns = `WData;
		end
		`WResp: begin
			if(BVALID && BREADY)
				ns = `IDLE;
			else
				ns = `WResp;
		end
		default: begin
			ns = `IDLE;
		end
	endcase
end

//READ CHANNEL
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		ARADDR_buf 	<= 32'd0;
		ARID_buf	<= 8'd0;
	end
	else if(cs == `RAddr) begin
		ARADDR_buf 	<= ARADDR;
		ARID_buf	<= ARID;
	end
end

always_comb begin
	if(cs == `RAddr) begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end
end

always_comb begin
	if(cs == `RData) begin
		RID 	= ARID_buf;
		RDATA 	= IP_sr1_data_out;
		RRESP 	= 2'b00;
		RLAST 	= 1'b1;
		RVALID 	= 1'b1;
	end
	else begin
		RID 	= 8'd0;
		RDATA 	= 32'd0;
		RRESP 	= 2'b00;
		RLAST 	= 1'b0;
		RVALID 	= 1'b0;
	end
end

//WRITE CHANNEL
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		AWADDR_buf 	<= 32'd0;
		AWID_buf	<= 8'd0;
	end
	else begin
		if(cs == `WAddr) begin
			AWADDR_buf 	<= AWADDR;
			AWID_buf	<= AWID;
		end
		else if(ns == `IDLE) begin
			AWADDR_buf 	<= 32'd0;
			AWID_buf	<= 8'd0;
		end
	end
end

always_comb begin
	if(cs == `WAddr) begin
		AWREADY = 1'b1;
	end
	else begin
		AWREADY = 1'b0;
	end
end

always_comb begin
	if(cs == `WData) begin
		WREADY = 1'b1;
	end
	else begin
		WREADY = 1'b0;
	end
end

always_comb begin
	if(cs == `WResp) begin
		BID 	= AWID_buf;
		BRESP 	= 2'b00;
		BVALID 	= 1'b1;
	end
	else begin
		BID 	= 8'd0;
		BRESP 	= 2'b00;
		BVALID 	= 1'b0;
	end
end


assign IP_inst = (AWADDR_buf[15:0] == 16'h4000 && IP_sr0_we) ? WDATA[1:0] : 2'd0;
assign IP_sr0_addr_in = (AWADDR_buf[15:0] == 16'h4000) ? 10'd0 : AWADDR_buf[11:2];
assign IP_sr0_data_in = (AWADDR_buf[15:0] == 16'h4000) ? 32'd0 : WDATA;
//assign IP_sr0_we = WVALID_S && reg_wready_s;
//assign IP_sr1_oe = reg_arready_s & ARVALID_S & ~reg_rvalid_s;
assign IP_sr0_we = (cs == `WData) ? 1'd1 : 1'd0;
assign IP_sr1_oe = (cs == `RData) ? 1'd1 : 1'd0;
assign IP_sr1_addr_in = ARADDR_buf[11:2];




IP_top ip_top_i(
.clk				(ACLK			),
.rst				(~ARESETn		),
.instr				(IP_inst		),
.sram_addr_in		(IP_sr0_addr_in	),
.sram_data_in		(IP_sr0_data_in	),
.sram0_we			(IP_sr0_we		),
.sram1_OE			(IP_sr1_oe		),
.sram1_addr_in		(IP_sr1_addr_in	),
.response_DO		(IP_sr1_data_out)
);

endmodule