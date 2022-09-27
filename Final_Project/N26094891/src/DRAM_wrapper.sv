`include "../include/AXI_define.svh"


`define Idle			4'd0  

`define ReadAddr_row	4'd1    
`define ReadAddr_col	4'd2  
`define ReadAddr_wait	4'd3    
`define ReadData		4'd4    

`define WriteAddr_row	4'd5    
`define WriteAddr_col	4'd6    
//`define WriteData		4'd7
`define WriteResp		4'd8    

`define Active			4'd9 


module DRAM_wrapper(
////////////////////////////////////////////
//read addr port
input logic [`AXI_IDS_BITS-1:0]   ARID,
input logic [`AXI_ADDR_BITS-1:0] ARADDR,
input logic [`AXI_LEN_BITS-1:0]  ARLEN,//burst len
input logic [`AXI_SIZE_BITS-1:0] ARSIZE,//burst size
input logic [1:0]                ARBURST,//burst type
input logic                      ARVALID,
output logic                     ARREADY,

//read data port
output logic [`AXI_IDS_BITS-1:0]  RID,
output logic [`AXI_DATA_BITS-1:0] RDATA,
output logic [1:0]               RRESP,
output logic                     RLAST,
output logic                     RVALID,
input logic                      RREADY,

//write addr port
input logic [`AXI_IDS_BITS-1:0]   AWID,
input logic [`AXI_ADDR_BITS-1:0] AWADDR,
input logic [`AXI_LEN_BITS-1:0]  AWLEN,
input logic [`AXI_SIZE_BITS-1:0] AWSIZE,
input logic [1:0]                AWBURST,
input logic                      AWVALID,
output logic                     AWREADY,

//write data port
input logic [`AXI_DATA_BITS-1:0] WDATA,
input logic [`AXI_STRB_BITS-1:0] WSTRB,
input logic                      WLAST,
input logic                      WVALID,
output logic                     WREADY,

//write response
output logic [`AXI_IDS_BITS-1:0] BID,
output logic [1:0]               BRESP,
output logic                     BVALID,
input logic                      BREADY,
////////////////////////////////////////////
input 							ACLK,
input 							ARESETn,



//DRAM output
input logic [31:0]				Q,
input logic						VALID,
//DRAM input
output logic					CSn,
output logic [3:0]				WEn,
output logic					RASn,
output logic					CASn,
output logic [10:0]				A,
output logic [31:0]				D
);
//-------------------
//DRAM_wrapper FSM
//-------------------

logic [20:0] addr_test;
assign addr_test = AWADDR[22:2];

assign CSn = 1'b0;

logic [3:0] cs, ns;
logic [`AXI_ADDR_BITS-1:0] reg_ARADDR;
logic [`AXI_IDS_BITS-1:0]  reg_ARID;
logic [`AXI_IDS_BITS-1:0] reg_AWID;
logic [`AXI_ADDR_BITS-1:0] reg_AWADDR;

logic [10:0] reg_row;
logic araddr_row_hit, awaddr_row_hit;

logic [2:0] cnt_write_pre_, cnt_write_pre;
logic [2:0] cnt_act_, cnt_act;
logic [2:0] cnt_read_pre_, cnt_read_pre;
logic [2:0] cnt_write_, cnt_write;

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cs <= `Idle;
	end
	else begin
		cs <= ns;	
	end	
end

always@(*)begin
	case(cs)
		`Active:begin
			if(cnt_act == 3'd5)
				ns = `Idle;
			else
				ns = `Active;
		end
		`Idle:begin
			if(ARVALID)begin
				if(araddr_row_hit)begin
					ns = `ReadAddr_col;
				end
				else begin
					ns = `ReadAddr_row;
				end
			end
			else if(AWVALID)begin
				if(awaddr_row_hit)begin
					ns = `WriteAddr_col;
				end
				else begin
					ns = `WriteAddr_row;
				end
			end
			else begin
				ns = `Idle;
			end
		end
		`ReadAddr_row:begin
			if(cnt_read_pre == 3'd5)
				ns = `Active;
			else
				ns = `ReadAddr_row;
		end
		
		`ReadAddr_col:begin
			if(ARVALID && ARREADY)
				ns = `ReadAddr_wait;
			else
				ns = `ReadAddr_col;
		end
		`ReadAddr_wait:begin
			if(VALID)
				ns = `ReadData;
			else
				ns = `ReadAddr_wait;
		end
		`ReadData:begin
			if(RREADY && RVALID && RLAST)
				ns = `Idle;
			else
				ns = `ReadData;
		end
		`WriteAddr_row:begin
			if(cnt_write_pre == 3'd5)
				ns = `Active;
			else
				ns = `WriteAddr_row;
		end
		`WriteAddr_col:begin
			if(WLAST && WVALID && WREADY)
				ns = `WriteResp;
			else
				ns = `WriteAddr_col;
		end
		`WriteResp:begin
			if(BVALID && BREADY)
				ns = `Idle;
			else
				ns = `WriteResp;
		end
		default:begin
			ns = `Idle;
		end
	endcase
end


//-------------------------------read-------------------------------//
///read addr channel
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_ARID	<= `AXI_IDS_BITS'd0;	
		reg_ARADDR	<= `AXI_ADDR_BITS'd0;
	end
	else if(cs == `Idle)begin
		reg_ARID	<= ARID;
		reg_ARADDR	<= ARADDR;
	end
	else begin
		reg_ARID	<= reg_ARID;
		reg_ARADDR	<= reg_ARADDR;
	end
end

always@(*)begin
	if(cs == `ReadAddr_col)begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end
end

///read data channel
logic [`AXI_DATA_BITS-1:0] reg_Q;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_Q	<= `AXI_DATA_BITS'd0;
	end
	else if(VALID)begin
		reg_Q	<= Q;
	end
	else begin
		reg_Q	<= reg_Q;
	end
end

always@(*)begin
	if(cs == `ReadData)begin
		RVALID	= 1'b1;
		RID 	= reg_ARID;
		RDATA	= reg_Q;
		RLAST	= 1'b1;
		RRESP	= 2'd0;
	end
	else begin
		RVALID	= 1'b0;
		RID		= 8'd0;
		RDATA	= 32'd0;
		RLAST 	= 1'b0;
		RRESP 	= 2'd0;
	end
end


//-------------------------------write-------------------------------//

///write address channel

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_AWID	<= `AXI_IDS_BITS'd0;
		reg_AWADDR	<= `AXI_ADDR_BITS'd0;
	end
	else if(cs == `Idle)begin
		reg_AWID	<= AWID;
		reg_AWADDR	<= AWADDR;
	end
	else begin
		reg_AWID	<= reg_AWID;
		reg_AWADDR	<= reg_AWADDR;
	end
end

///write data channel
always@(*)begin
	if((cs == `Idle) && (awaddr_row_hit))begin
		AWREADY = 1'b1;
	end
	else begin
		AWREADY = 1'b0;
	end
end



always@(*)begin
	if((cs == `WriteAddr_col) && (cnt_write == 3'd5))begin
		WREADY = 1'b1;
	end
	else begin
		WREADY = 1'b0;
	end
end


///write response
always@(*)begin
	if(cs == `WriteResp)begin
		BRESP = 2'b00;
		BVALID = 1'b1;
		BID = reg_AWID;
	end
	else begin
		BRESP = 2'b11;
		BVALID = 1'b0;
		BID = 8'd0;
	end
end



always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cnt_act_ 		<= 3'd0;
		cnt_read_pre_ 	<= 3'd0;
		cnt_write_pre_	<= 3'd0;
		cnt_write_		<= 3'd0;
	end
	else begin
		cnt_act_ 		<= cnt_act;
		cnt_read_pre_ 	<= cnt_read_pre;
		cnt_write_pre_	<= cnt_write_pre;
		cnt_write_		<= cnt_write;
	end
end
/*
///cnt
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cnt_act 	<= 3'd0;
	end
	else begin
		if(cs == `Active)begin
			cnt_act 	<= cnt_act + 3'd1;
		end
		else begin
			cnt_act 	<= 3'd0;
		end
	end
end
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cnt_read_pre 	<= 3'd0;
	end
	else begin
		if(cs == `ReadAddr_row)begin
			cnt_read_pre 	<= cnt_read_pre + 3'd1;
		end
		else begin
			cnt_read_pre 	<= 3'd0;
		end
	end
end
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cnt_write_pre 	<= 3'd0;
	end
	else begin
		if(cs == `WriteAddr_row)begin
			cnt_write_pre 	<= cnt_write_pre + 3'd1;
		end
		else begin
			cnt_write_pre 	<= 3'd0;
		end
	end
end
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		cnt_write 	<= 3'd0;
	end
	else begin
		if(cs == `WriteAddr_col)begin
			cnt_write 	<= cnt_write + 3'd1;
		end
		else begin
			cnt_write 	<= 3'd0;
		end
	end
end
*/





always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		reg_row <= 11'd0;
	end
	else begin
		if(cs == `Active && ARVALID)begin
			//reg_row <= reg_ARADDR[22:12];
			reg_row <= ARADDR[22:12];
		end
		else if(cs == `Active && AWVALID)begin
			//reg_row <= reg_AWADDR[22:12];
			reg_row <= AWADDR[22:12];
		end
		else begin
			reg_row <= reg_row;
		end
	end
end



assign araddr_row_hit = (reg_row == ARADDR[22:12]) ? 1'b1 : 1'b0;
assign awaddr_row_hit = (reg_row == AWADDR[22:12]) ? 1'b1 : 1'b0;

always@(*)begin
	case(cs)
		`Active:begin
			if(cnt_act_ == 3'd0)begin
				WEn		= 4'b1111;
				RASn	= 1'b0;
				CASn	= 1'b1;
				if(ARVALID)begin
					A = reg_ARADDR[22:12];
				end
				else begin
					A = reg_AWADDR[22:12];
				end
				D		= 32'd0;
			end
			else begin
				WEn		= 4'b1111;
				RASn	= 1'b1;
				CASn	= 1'b1;
				A		= 11'd0;
				D		= 32'd0;
			end
			
			cnt_act			= cnt_act_ + 3'd1;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`Idle:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b1;
			A		= 11'd0;
			D		= 32'd0;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`ReadAddr_row:begin//Precharge
			if(cnt_read_pre_ == 3'd0)begin
				WEn		= 4'b0000;
				RASn	= 1'b0;
				CASn	= 1'b1;
				A		= reg_row;
				D		= 32'd0;
			end
			else begin
				WEn		= 4'b1111;
				RASn	= 1'b1 ;
				CASn	= 1'b1;
				A		= 11'd0;
				D		= 32'd0;
			end
			
			cnt_act			= 3'd0;
			cnt_read_pre	= cnt_read_pre_ + 3'd1;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`ReadAddr_col:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b0;
			A		= {1'b0, reg_ARADDR[11:2]};
			D		= 32'd0;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`ReadAddr_wait:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b1;
			A		= 11'd0;
			D		= 32'd0;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`ReadData:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b1;
			A		= 11'd0;
			D		= 32'd0;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		`WriteAddr_row:begin//Precharge
			if(cnt_write_pre_ == 3'd0)begin
				WEn		= 4'b0000;
				RASn	= 1'b0;
				CASn	= 1'b1;
				A		= reg_row;
				D		= 32'd0;
			end
			else begin
				WEn		= 4'b1111;
				RASn	= 1'b1;
				CASn	= 1'b1;
				A		= 11'd0;
				D		= 32'd0;
			end
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= cnt_write_pre_ + 3'd1;
			cnt_write		= 3'd0;
			
		end
		
		`WriteAddr_col:begin//WriteData
			if(cnt_write_ == 3'd0)begin
				WEn		= WSTRB;
				RASn	= 1'b1;
				CASn	= 1'b0;
				A		= {1'b0, reg_AWADDR[11:2]};
				D		= WDATA;
			end
			else begin
				WEn		= 4'b1111;
				RASn	= 1'b1;
				CASn	= 1'b1;
				A		= {1'b0, reg_AWADDR[11:2]};
				D		= WDATA;
			end
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= cnt_write_ + 3'd1;
			
		end
		/*
		`WriteData:begin
			if(cnt_write_ == 3'd0)begin
				WEn		= WSTRB;
				RASn	= 1'b1;
				CASn	= 1'b0;
				A		= {1'b0, reg_AWADDR[11:2]};
				D		= WDATA;
			end
			else begin
				WEn		= 4'b1111;
				RASn	= 1'b1;
				CASn	= 1'b1;
				A		= {1'b0, reg_AWADDR[11:2]};
				D		= WDATA;
			end
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= cnt_write_ + 3'd1;
		end
		*/
		`WriteResp:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b1;
			A		= 11'd0;
			D		= WDATA;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
		
		default:begin
			WEn		= 4'b1111;
			RASn	= 1'b1;
			CASn	= 1'b1;
			A		= 11'd0;
			D		= 32'd0;
			
			cnt_act			= 3'd0;
			cnt_read_pre	= 3'd0;
			cnt_write_pre	= 3'd0;
			cnt_write		= 3'd0;
			
		end
	endcase
end

endmodule
