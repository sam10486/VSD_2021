//Written by JJHu
`include "../include/AXI_define.svh"
`define IDLE 2'b00
`define READ_ADDR 2'b01
`define READ_DATA 2'b10
 
module ROM_wrapper (
	input logic ACLK,
	input logic ARESETn,
	
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
	
	
	//READ ADDR
	input logic [`AXI_IDS_BITS-1:0] ARID,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR,
	input logic [`AXI_LEN_BITS-1:0] ARLEN,
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	input logic [1:0] ARBURST,
	input logic 	   ARVALID,
	output logic       ARREADY,
	
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input logic  RREADY,
	
	input logic [31:0] ROM_o,
	
	output logic ROM_OE,
	output logic ROM_CS,
	output logic [11:0] ROM_A
);
logic [1:0] CS;
logic [1:0] NS;

//FSM CS <= NS
always@(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn)begin
		CS <= `IDLE;
	end
	else begin
		CS <= NS;
	end

end


//FSM
always_comb begin
	case(CS)
	`IDLE: begin
		if(ARVALID) begin
			NS = `READ_ADDR;
		end
		else begin
			NS = `IDLE; 
		end
	end
	`READ_ADDR: begin
		if(ARVALID && ARREADY) begin
			NS = `READ_DATA;
		end
		else begin
			NS = `READ_ADDR;
		end
	end
	
	`READ_DATA: begin
		if(RREADY && RVALID && RLAST) begin
			NS = `IDLE;
		end
		else begin
			NS = `READ_DATA;
		end
	end
	default: begin
		NS = `IDLE;
	end
	endcase
	
end


logic [`AXI_ADDR_BITS-1:0] araddr_reg;
always@(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn)begin
		araddr_reg <= `AXI_ADDR_BITS'd0;
	end
	else if(CS == `IDLE)begin
		araddr_reg <= ARADDR;
	end
	else begin
		araddr_reg <= araddr_reg;
	end
end

logic [7:0] arid_reg;
always@(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn)begin
		arid_reg <= 8'd0;
	end
	else if(CS == `IDLE)begin
		arid_reg <= ARID;
	end
	else begin
		arid_reg <= arid_reg;
	end
end



always@(*)begin
	case(CS)
		`READ_ADDR:begin
			ARREADY	= 1'd1;	
			RVALID	= 1'b0;
			RRESP	= 2'd0;
			RDATA	= 32'd0;
			RLAST	= 1'b0;
			RID		= 8'd0;

			ROM_OE	= 1'b0;
			ROM_CS	= 1'b1;
			ROM_A	= ARADDR[13:2]; 

			AWREADY	= 1'b0;
			WREADY	= 1'b0;
			BID		= 8'd0;
			BRESP	= 2'b11;
			BVALID	= 1'b0;
		end
		`READ_DATA:begin
			ARREADY	= 1'd0;
			RVALID	= 1'b1;
			RRESP	= 2'd0;
			RDATA	= ROM_o;
			RLAST	= 1'b1;
			RID		= arid_reg;

			ROM_OE	= 1'b1;
			ROM_CS	= 1'b1;
			ROM_A	= araddr_reg[13:2];

			AWREADY	= 1'b0;
			WREADY	= 1'b0;
			BID		= 8'd0;
			BRESP	= 2'b11;
			BVALID	= 1'b0;
		end
		default:begin
			ARREADY	= 1'd0;
			RVALID	= 1'd0;
			RRESP	= 2'd0;
			RDATA	= 32'd0;
			RLAST	= 1'd0;
			RID		= 8'd0;

			ROM_OE	= 1'd0;
			ROM_CS	= 1'd0;
			ROM_A	= 12'd0;

			AWREADY	= 1'b0;
			WREADY	= 1'b0;
			BID		= 8'd0;
			BRESP	= 2'b11;
			BVALID	= 1'b0;	
		end
	endcase
end




endmodule
