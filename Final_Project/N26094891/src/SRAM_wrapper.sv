`include "../include/AXI_define.svh"

`define Idle      3'b000
`define ReadAddr  3'b001
`define ReadData  3'b010
`define WriteAddr 3'b011
`define WriteData 3'b100
`define WriteResp 3'b101

module SRAM_wrapper(
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
input 							ARESETn

);


///------------------------------------------------------///
logic [2:0] cs, ns;

//SRAM port
logic [13:0] A;
logic OE, chipsel;
logic [31:0] DO;
logic [31:0] DI;
logic [3:0] WEB;


always @(posedge ACLK or negedge ARESETn)begin
	if(!ARESETn)begin
		cs <= `Idle;
	end
	else begin
		cs <= ns;
	end
end

always@(*)begin
	case(cs)
		`Idle:begin
			if(ARVALID)
				ns = `ReadAddr;
			else if(AWVALID)
				ns = `WriteAddr;
			else
				ns = `Idle;
		end
		`WriteAddr:begin
			if(AWVALID && AWREADY)
				ns = `WriteData;
			else
				ns = `WriteAddr;
		end
		`WriteData:begin
			if(WLAST && WVALID && WREADY)
				ns = `WriteResp;
			else
				ns = `WriteData;
		end
		`WriteResp:begin
			if(BVALID && BREADY)
				ns = `Idle;
			else
				ns = `WriteResp;
		end
		`ReadAddr:begin
			if(ARVALID && ARREADY)
				ns = `ReadData;
			else
				ns = `ReadAddr;
		end
		`ReadData:begin
			if(RREADY && RVALID && RLAST)
				ns = `Idle;
			else
				ns = `ReadData;
		end
		default:begin
			ns = `Idle;
		end
	endcase
end


///read addr channel
logic [`AXI_IDS_BITS-1:0]   reg_arid;
logic [`AXI_ADDR_BITS-1:0] reg_araddr;
logic [`AXI_ADDR_BITS-1:0] reg_araddr_4;
logic [`AXI_LEN_BITS-1:0]  reg_arlen;//burst len
logic [`AXI_SIZE_BITS-1:0] reg_arsize;//burst size
logic [1:0]                reg_arburst;//burst type

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_arid    <= 8'd0;
		//reg_araddr  <= 32'd0;
		reg_araddr_4 <= 32'd0;
		reg_arlen   <= 4'd0;
		reg_arsize  <= 3'd0;
		reg_arburst <= 2'd0;	
	end
	else if(cs == `Idle)begin
		reg_arid    <= ARID;
		//reg_araddr  <= ARADDR;
		reg_araddr_4 <= ARADDR + 32'd4;
		reg_arlen   <= ARLEN;
		reg_arsize  <= ARSIZE;
		reg_arburst <= ARBURST;
	end
	else begin
		reg_arid    <= reg_arid;
		//reg_araddr  <= reg_araddr;
		reg_araddr_4 <= reg_araddr_4;
		reg_arlen   <= reg_arlen;
		reg_arsize  <= reg_arsize;
		reg_arburst <= reg_arburst;
	end
end

always@(*)begin
	if(cs == `ReadAddr)begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end
end



///read data channel

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		RVALID <= 1'b0;
		reg_araddr <=32'd0;
	end
	else if(cs == `Idle)begin
		RVALID <= 1'b0;
		reg_araddr  <= ARADDR;	
	end
	else if(cs == `ReadData)begin
		if(RVALID && RREADY)begin
			RVALID <= 1'b0;
			reg_araddr <= reg_araddr + 32'd4;		
		end
		else if(~RVALID)begin
			RVALID <= 1'b1;
			reg_araddr <= reg_araddr;
		end
	end
	else begin
		RVALID <= 1'b0;
		reg_araddr <= reg_araddr;
	end
end



always@(*)begin
	if(cs == `ReadData)begin
		//RVALID = 1'b1;
		RID = reg_arid;
	end
	else begin
		//RVALID = 1'b0;
		RID = 8'd0;
	end
end

/*
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		RDATA = 32'd0;
	end
	else if(RREADY && RVALID)begin
		RDATA = DO;
	end
	else begin
		RDATA = RDATA;
	end
end
*/
//assign RDATA = (RREADY && RVALID) ? DO : 32'd0;

assign RDATA = (cs == `ReadData) ? DO : 32'd0;

logic [`AXI_LEN_BITS-1:0]  reg_arlen_cnt;

always@(*)begin
	if(cs == `ReadData)begin
		if(reg_arlen_cnt == reg_arlen)begin
			RLAST = 1'b1;
			RRESP = 2'b0;
		end
		else begin
			RLAST = 1'b0;
			RRESP = 2'b0;
		end	
	end
	else begin
		RLAST = 1'b0;
		RRESP = 2'b0;
	end
end

///logic [`AXI_ADDR_BITS-1:0] reg_araddr_cnt;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_arlen_cnt <= 4'd0;
		///reg_araddr_cnt <= 32'd0;
	end
	else if(cs == `ReadData)begin
		if(RVALID && RREADY)begin
			reg_arlen_cnt <= reg_arlen_cnt + 4'd1;
			///reg_araddr_cnt <= reg_araddr + 32'd4;
		end
		else begin
			reg_arlen_cnt <= reg_arlen_cnt;
			///reg_araddr_cnt <= reg_araddr;
		end
	end
	else begin
		reg_arlen_cnt <= 4'b0;
		///reg_araddr_cnt <= reg_araddr_cnt;
	end
end


assign OE = (cs == `ReadData) ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------------------------------///
///write address channel
logic [`AXI_IDS_BITS-1:0]   reg_awid;
logic [`AXI_ADDR_BITS-1:0] reg_awaddr;
logic [`AXI_LEN_BITS-1:0]  reg_awlen;
logic [`AXI_SIZE_BITS-1:0] reg_awsize;
logic [1:0]                reg_awburst;
logic                      reg_awvalid;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_awid <= 8'd0;
		reg_awaddr <= 32'd0;
		reg_awlen <= 4'd0;
		reg_awsize <= 3'd0;
		reg_awburst <= 2'd0;
		reg_awvalid <= 1'b0;
	end
	else if(cs == `Idle)begin
		reg_awid <= 8'd0;
		reg_awaddr <= 32'd0;
		reg_awlen <= 4'd0;
		reg_awsize <= 3'd0;
		reg_awburst <= 2'd0;
		reg_awvalid <= 1'b0;
	end
	else if(cs == `WriteAddr)begin
		reg_awid <= AWID;
		reg_awaddr <= AWADDR;
		reg_awlen <= AWLEN;
		reg_awsize <= AWSIZE;
		reg_awburst <= AWBURST;
		reg_awvalid <= AWVALID;
	end
	else begin
		reg_awid <= reg_awid;
		reg_awaddr <= reg_awaddr;
		reg_awlen <= reg_awlen;
		reg_awsize <= reg_awsize;
		reg_awburst <= reg_awburst;
		reg_awvalid <= reg_awvalid;
	end
end

always@(*)begin
	if(cs == `WriteAddr)begin
		AWREADY = 1'b1;
	end
	else begin
		AWREADY = 1'b0;
	end
end

///write data channel
always@(*)begin
	if(cs == `WriteData)begin
		WREADY = 1'b1;
	end
	else begin
		WREADY = 1'b0;
	end
end

logic [3:0] reg_awaddr_cnt;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		reg_awaddr_cnt <= 4'd0;
	end
	else if(WREADY && WVALID && BREADY)begin
		reg_awaddr_cnt <= reg_awaddr_cnt + 4'd1;
	end
	else begin
		reg_awaddr_cnt <= 4'd0;
	end
end
assign DI = WDATA;



///write response
always@(*)begin
	if(cs == `WriteResp)begin
		BRESP = 2'b00;
		BVALID = 1'b1;
		BID = reg_awid;
	end
	else begin
		BRESP = 2'b11;
		BVALID = 1'b0;
		BID = 8'd0;
	end
end

///SRAM signal
always@(*)begin
	
	if(cs == `ReadAddr)begin
		A = ARADDR[15:2];//(RVALID && RREADY) ? reg_araddr_4[15:2] : reg_araddr[15:2];
	end
	else if(cs == `ReadData)begin
		A = reg_araddr[15:2];
	end
	
	/*
	if(cs == `ReadAddr)begin
		A = reg_araddr[15:2];
	end
	*/
	else if(cs == `WriteData)begin
		A = reg_awaddr[15:2] + {{10'b0},reg_awaddr_cnt};
	end
	else begin
		A = 14'd0;
	end
end


always@(*)begin
	if(cs == `WriteData)begin
		WEB = WSTRB;
	end
	else begin
		WEB = 4'b1111;
	end
end

always@(*)begin
	if(cs == `ReadAddr || cs == `ReadData || cs == `WriteData)begin
		chipsel = 1'b1;
	end
	else begin
		chipsel = 1'b0;
	end
end
///------------------------------------///
SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (ACLK  ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (chipsel)
);

endmodule
