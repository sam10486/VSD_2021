`include "AXI_define.svh"

`define IDLE    3'b000
`define RAddr 	3'b001
`define RData 	3'b010
`define WAddr 	3'b011
`define WData  	3'b100
`define WResp  	3'b101
`define Buffer	3'b110

module ROM_wrapper (
	
	input ACLK,
	input ARESETn,
	
	/*
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
	*/
	
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic[`AXI_IDS_BITS-1:0] RID,
	output logic[`AXI_DATA_BITS-1:0] RDATA,
	output logic[1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,
	
	//ROM output
	input [31:0]ROM_out,
	//ROM input
	output logic ROM_CS,
	output logic ROM_OE,
	output logic [11:0] ROM_A
);

logic	[2:0]	cs,ns;
logic	[`AXI_IDS_BITS-1:0] ARID_buf;

//FSM
always @(posedge ACLK or negedge ARESETn) begin
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
		default: begin
				ns = `IDLE;
		end
	endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
			ARID_buf	<= 8'd0;
	end
	else begin
		if(cs == `RAddr) begin
			ARID_buf	<= ARID;
		end
		else if(cs == `IDLE) begin
			ARID_buf	<= 8'd0;
		end
	end
end

//RAddr Channel
always_comb begin
	if(cs == `RAddr) begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end
end

//RData Channel
always_comb begin
	if(cs == `RData) begin
		RID		= ARID_buf;
		RDATA	= ROM_out;
		RRESP	= 2'b00;
		RLAST	= 1'b1;
		RVALID	= 	1'b1;
	end
	else begin
		RID		= 8'd0;
		RDATA	= 32'd0;
		RRESP	= 2'b00;
		RLAST	= 1'b0;
		RVALID	= 	1'b0;
	end
end

//ROM Signal
always_comb begin
	case(cs)
		`RAddr: begin
			ROM_CS 	= 1'b1;
			ROM_OE 	= 1'b0;
			ROM_A	= ARADDR[13:2];
		end
		`RData: begin
			ROM_CS 	= 1'b0;
			ROM_OE 	= 1'b1;
			ROM_A	= 12'd0;
		end
		default: begin
			ROM_CS 	= 1'b0;
			ROM_OE 	= 1'b0;
			ROM_A	= 12'd0;
		end
	endcase
end

endmodule