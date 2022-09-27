`include "AXI_define.svh"

module sctrl_wrapper(
	input logic ACLK,
	input logic ARESETn,
	input logic [31:0] sctrl_out,//from sensor_ctrl
	
	output logic sctrl_en,
	output logic sctrl_clear,
	output logic [5:0] sctrl_addr,
	//AW
	input logic [ 7:0] AWID,
	input logic [31:0] AWADDR,
	input logic [ 3:0] AWLEN,
	input logic [ 2:0] AWSIZE,
	input logic [ 1:0] AWBURST,
	input logic AWVALID,
	output logic AWREADY, 
	//W
	input logic [31:0] WDATA,
	input logic [ 3:0] WSTRB,
	input logic WLAST,
	input logic WVALID,
	output logic WREADY,
	
	//B
	output logic [ 7:0] BID,
	output logic [ 1:0] BRESP,
	output logic BVALID,
	input  logic BREADY,
	
	//AR
	input logic [ 7:0] ARID,
	input logic [31:0] ARADDR,
	input logic [ 3:0] ARLEN,
	input logic [ 2:0] ARSIZE,
	input logic [ 1:0] ARBURST,
	input logic ARVALID,
	output logic ARREADY,
	
	//R
	output logic [ 7:0] RID,
	output logic [31:0] RDATA,
	output logic [ 1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input logic  RREADY



);
//jjhu 12172021
	logic [2: 0] cs, ns;
	logic sctrl_en_delay;
	localparam 	idle = 3'd0,
				read_address = 3'd1,
				read_data = 3'd2,
				write_address = 3'd3 ,
				write_data = 3'd4,
				write_b = 3'd5;

	always@(posedge ACLK or negedge ARESETn) begin
		if(~ARESETn) cs <= idle;
		else cs <= ns;
	end
	
	//FSM
	always_comb begin
	case(cs)
		idle: begin
			if(ARVALID) ns = read_address;
			else if (AWVALID) ns= write_address;
			else ns = idle;
		end
		read_address: begin
			if(ARVALID&&ARREADY) ns = read_data;
			else ns = read_address;
			
		end
		
		read_data: begin
			if(RVALID&&RREADY) ns= idle;
			else ns= read_data;
		end
		
		write_address: begin
			if(AWVALID&&AWREADY) ns= write_data;
			else ns = write_address;
		end
		
		write_data: begin
			if(WVALID&&WREADY) ns= write_b;
			else ns = write_data;
		end
		
		write_b: begin
			if(BVALID&&BREADY) ns= idle;
			else ns = write_b;
		end
		
		default: begin
			ns = idle;
		end
		
	endcase
	end
/*
sctrl_en/
sctrl_clear/

sctrl_addr
AWREADY/
WREADY/

BID/
BRESP/
BVALID/
ARREADY/
RID/
RDATA/
RRESP/
RLAST/
RVALID/
*/

always@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		sctrl_en <= 1'd0;
	end
	else begin
		sctrl_en <= sctrl_en_delay;
	end
end

logic [31:0] AWADDR_delay;
always@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		AWADDR_delay <= 32'd0;
	end
	else begin
		AWADDR_delay <= AWADDR;
	end
end


always_comb begin
	if(AWADDR_delay == 32'h1000_0100) begin//stcrl_en
		if(WDATA!=32'd0) begin
			sctrl_en_delay	=	1'd1;//buffer ?
			sctrl_clear	=	1'd0;
		end
		else begin
			sctrl_en_delay	=	sctrl_en;	
			sctrl_clear	=	1'd0;		
		end
	end
	
	else if(AWADDR_delay == 32'h1000_0200) begin//stcrl_clear
		if(WDATA!=32'd0) begin
			sctrl_en_delay	=	sctrl_en;
			sctrl_clear	=	1'd1;
		end
		else begin
			sctrl_en_delay	=	sctrl_en;
			sctrl_clear	=	1'd0;		
		end	
	
	end
	
	else begin
		sctrl_en_delay	=	sctrl_en;
		sctrl_clear	=	1'd0;
	
	end

end
assign sctrl_addr = ARADDR[7:2];
logic [7: 0] ARID_dely;
logic [31:0] sctrl_out_delay;
//ARID_dely
	always@(posedge ACLK or negedge ARESETn) begin
		if(~ARESETn)  ARID_dely <= 8'd0;
		else if(cs==read_address) ARID_dely <= ARID ;
		else if(cs==idle) ARID_dely <= 8'd0;
		else ARID_dely <= ARID_dely;
	end
	
	always@(posedge ACLK or negedge ARESETn) begin
		if(~ARESETn)  sctrl_out_delay <= 32'd0;
		else if(cs==read_address) sctrl_out_delay <= sctrl_out ;
		else if(cs==idle) sctrl_out_delay <= 32'd0;
		else sctrl_out_delay <= sctrl_out_delay;
	end

	always_comb begin
		if(cs==read_data) begin
			RID		=	ARID_dely;//with buffer
			RDATA	=	sctrl_out_delay;//with buffer
			RRESP	=	2'd0;
			RLAST	=	1'd1;
			RVALID	=	1'd1;
		end
		
		else begin
			RID		=	8'd0;
			RDATA	=	32'd0;
			RRESP	=	2'd0;
			RLAST	=	1'd0;
			RVALID	=	1'd0;
		end
	
	end
	always_comb begin
		if(cs==read_address) begin
			ARREADY	=	1'd1;
		end
		else begin
			ARREADY	=	1'd0;
		end
	
	end
	
	assign	BRESP	=	2'd0;
	
	always_comb begin
		if(cs==write_b) begin
			BVALID	=	1'd1;
		end
		else begin
			BVALID	=	1'd0;
		end
	end
	
	always_comb begin
		if(cs==write_data) begin
			WREADY	=	1'd1;
		end
		else begin
			WREADY	=	1'd0;
		end
	end
	
	always_comb begin
		if(cs==write_address) begin
			AWREADY	=	1'd1;
		end
		else begin
			AWREADY	=	1'd0;
		end
	end
	
	
endmodule