`include "../include/AXI_define.svh"
`include "../include/def.svh"
`include "CPU.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"


`define Idle      3'b000
`define ReadAddr  3'b001
`define ReadData  3'b010
`define WriteAddr 3'b011
`define WriteData 3'b100
`define WriteResp 3'b101
`define Wait	  3'b110

module CPU_wrapper(
input ACLK,
input ARESETn,
//-------------------------------------------//
/////////////////IM/////////////////
//----read address----//
output logic [`AXI_ID_BITS-1:0]   ARID_M0,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M0,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
output logic [1:0]                ARBURST_M0,
output logic                      ARVALID_M0,
input                             ARREADY_M0,
//----read data----//
input [`AXI_ID_BITS-1:0]          RID_M0,
input [`AXI_DATA_BITS-1:0] 		  RDATA_M0,
input [1:0]                       RRESP_M0,
input                             RLAST_M0,
input                             RVALID_M0,
output logic                      RREADY_M0,
/////////////////DM/////////////////
//----read address----//
output logic [`AXI_ID_BITS-1:0]   ARID_M1,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M1,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
output logic [1:0]                ARBURST_M1,
output logic                      ARVALID_M1,
input                             ARREADY_M1,
//----read data----//
input [`AXI_ID_BITS-1:0]          RID_M1,
input [`AXI_DATA_BITS-1:0] 		  RDATA_M1,
input [1:0]                       RRESP_M1,
input                             RLAST_M1,
input                             RVALID_M1,
output logic                      RREADY_M1,
//----write address----//
output logic [`AXI_ID_BITS-1:0]   AWID_M1,
output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
output logic [`AXI_LEN_BITS-1:0]  AWLEN_M1,
output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
output logic [1:0]                AWBURST_M1,
output logic                      AWVALID_M1,
input                             AWREADY_M1,
//----write data----//
output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
output logic                      WLAST_M1,
output logic                      WVALID_M1,
input                             WREADY_M1,
//----write response----//
input [`AXI_ID_BITS-1:0]          BID_M1,
input [1:0]                       BRESP_M1,
input                             BVALID_M1,
output logic                      BREADY_M1,
//-------------------------------------------//
input interrupt
);


logic IM_CS, IM_OE, DM_CS, DM_OE;
logic [3:0] IM_WEB, DM_WEB;
logic [31:0] IM_addr, IM_output, DM_addr, DM_output, DM_input;
logic CPU_Ready;

logic [2:0] cs_m0, ns_m0, cs_m1, ns_m1;
//jjhu
logic core_req_D, core_req_I;
logic I_wait, D_wait;
logic [31:0] DM_data_out, IM_data_out;
logic DM_wait;
logic IM_wait;
logic D_req, I_req;
logic [`DATA_BITS-1:0] D_addr, I_addr;
logic [`DATA_BITS-1:0] D_in, I_in;
logic [`CACHE_TYPE_BITS-1:0] D_type, I_type; 
logic D_write, I_write;
logic IM_Read, DM_Read, DM_Write;


logic [31:0] IM_output_buff;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		IM_output_buff <= 32'd0;
	end
	else begin
		IM_output_buff <= IM_data_out;
	end
end


logic [31:0] DM_output_buff;
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		DM_output_buff <= 32'd0;
	end
	else if(DM_wait)begin
		DM_output_buff <= DM_data_out;
	end
	else begin
		DM_output_buff <= DM_output_buff;
	end
end


logic [2:0] DM_type;
CPU CPU1(
	.clk(ACLK), 
	.rst(~ARESETn),
	//output	
	.IM_CS(IM_CS), 
	.IM_OE(IM_OE), 
	.IM_WEB(IM_WEB), 
	.IM_addr(IM_addr),
	//input
	.IM_output(IM_output_buff),
	
	//output
	.DM_CS(DM_CS), 
	.DM_OE(DM_OE), 
	.DM_WEB(DM_WEB), 
	.DM_addr(DM_addr), 
	.DM_input(DM_input),
	//input
	.DM_output(DM_output_buff), ///
	
	//input
	.CPU_Ready(CPU_Ready),
	.cs_m0(cs_m0),
	.ns_m0(ns_m0),
	.cs_m1(cs_m1),
	.ns_m1(ns_m1),
	.EXMEM_Cache_type(DM_type),
	.interrupt(interrupt));
	
assign IM_Read = IM_CS && IM_OE;
assign DM_Read = DM_CS && DM_OE;
assign DM_Write = DM_CS && (DM_WEB != 4'b1111);

//jjhu
assign core_req_I = (IM_Read)? 1'd1: 1'd0;
assign core_req_D = (DM_Read || DM_Write)? 1'd1: 1'd0;

//jjhu

//assign I_wait = (cs_m0 == `Idle) ? 1'd0 : 1'd1;
//assign D_wait = (cs_m1 == `Idle) ? 1'd0 : 1'd1;


always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		I_wait <= 1'b1; 
	end
	else begin
		if(cs_m0 == `ReadData && ns_m0 == `Idle) begin
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
		if(((cs_m1 == `ReadData)||(cs_m1 == `WriteResp)) && ns_m1 == `Idle) begin
			D_wait <= 1'b0;
		end
		else begin
			D_wait <= 1'b1;
		end
	end
end






L1C_inst L1CI (
  .clk(ACLK),
  .rst(!ARESETn),
  //input
  // CPU to Cache
  .core_addr(IM_addr),
  .core_req(core_req_I),
  .core_write(1'd0),
  .core_in(32'd0),
  .core_type(`CACHE_WORD),//func3
  // CPU Wrapper to Cache
  .I_out(IM_output),
  .I_wait(I_wait),
  
  //output
  // Cache to CPU
  .core_out(IM_data_out),
  .core_wait(IM_wait),
  // Cache to CPU Wrapper
  .I_req(I_req),
  .I_addr(I_addr),
  .I_write(I_write),
  .I_in(I_in),
  .I_type(I_type)

);



L1C_data L1CD (
  .clk(ACLK),
  .rst(!ARESETn),
  //input
  // CPU to Cache
  .core_addr(DM_addr),
  .core_req((CPU_Ready)?1'b0:core_req_D),
  .core_write(DM_Write),
  .core_in(DM_input),
  .core_type(DM_type),//func3
  // CPU Wrapper to Cache
  .D_out(DM_output),
  .D_wait(D_wait),
  
  //output
  // Cache to CPU
  .core_out(DM_data_out),
  .core_wait(DM_wait),
  // Cache to CPU Wrapper
  .D_req(D_req),
  .D_addr(D_addr),
  .D_write(D_write),
  .D_in(D_in),
  .D_type(D_type)
);





//----------------M0 FSM----------------//
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		cs_m0 <= `Idle;
	end
	else begin
		cs_m0 <= ns_m0;
	end
end

always@(*)begin
	case(cs_m0)
		`Idle:begin
			if(I_req && (~I_write))begin
				ns_m0 = `ReadAddr;
			end
			else begin
				ns_m0 = `Idle;
			end
		end
		`ReadAddr:begin
			if(ARVALID_M0 && ARREADY_M0)begin
				ns_m0 = `ReadData;
			end
			else begin
				ns_m0 = `ReadAddr;
			end
		end
		`ReadData:begin
			if(RLAST_M0 && RREADY_M0 && RVALID_M0)begin
				//ns_m0 = `Wait;
				ns_m0 = `Idle;
			end
			else begin
				ns_m0 = `ReadData;
			end
		end
		
		default:begin
			ns_m0 = `Idle;
		end
	endcase
end

///-------------M0 read address(IM)-------------///
always@(*)begin
	if(ARVALID_M0)begin
		ARID_M0		= 4'd1;
		ARLEN_M0 	= 4'd0;
		ARSIZE_M0 	= 3'd2;
		ARBURST_M0 	= 2'd1;
	end
	else begin
		ARID_M0 	= 4'd0;
		ARLEN_M0 	= 4'd0;
		ARSIZE_M0 	= 3'd0;
		ARBURST_M0 	= 2'd0;
	end
end

/*
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARADDR_M0 <= 32'd0;
	end
	else if(ARVALID_M0)begin
		ARADDR_M0 <= ARADDR_M0;
	end
	else begin
		//ARADDR_M0 <= IM_addr;
		ARADDR_M0 <= I_addr;
	end
end
*/
always@(*)begin
	if(ARVALID_M0)begin
		ARADDR_M0 = I_addr;
	end
	else begin
		//ARADDR_M0 <= IM_addr;
		ARADDR_M0 = 32'd0;
	end
end
/*
always@(*)begin
	if((cs_m0 == `ReadAddr) && I_req )begin
		ARVALID_M0 = 1'b1;
	end
	else begin
		ARVALID_M0 = 1'b0;
	end
end
*/
/*
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARVALID_M0 <= 1'b0;
	end
	else if(ARVALID_M0 && ARREADY_M0)begin
		ARVALID_M0 <= 1'b0;
	end
	else if((cs_m0 == `Idle) && IM_Read)begin
		ARVALID_M0 <= 1'b1;
	end
end
*/

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARVALID_M0 <= 1'b0;
	end
	else if(ARVALID_M0 && ARREADY_M0)begin
		ARVALID_M0 <= 1'b0;
	end
	else if((cs_m0 == `Idle) && I_req && (~I_write))begin
		ARVALID_M0 <= 1'b1;
	end
end

///-------------M0 read data(IM)-------------///
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		RREADY_M0 <= 1'b0;
	end
	else if(RREADY_M0)begin
		RREADY_M0 <= 1'b0;
	end
	else if(~RREADY_M0 && RVALID_M0)begin
		RREADY_M0 <= 1'b1;
	end
end

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		IM_output <= 32'd0;
	end
	else if(RREADY_M0 && RVALID_M0)begin
		IM_output <= RDATA_M0;
	end
end

/*
assign IM_output = RDATA_M0;
*/




//////////////////////////////////////////////////////////////////////////////////////
//-------------------M1 FSM-------------------//
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		cs_m1 <= `Idle;
	end
	else begin
		cs_m1 <= ns_m1;
	end
end

always@(*)begin
	case(cs_m1)
		`Idle:begin
			if(D_req && (!D_write))begin
				ns_m1 = `ReadAddr;
			end
			else if(D_req && D_write)begin//jjhu
				ns_m1 = `WriteAddr;
			end
			else begin
				ns_m1 = `Idle;
			end
		end
		`ReadAddr:begin
			if(ARVALID_M1 && ARREADY_M1)begin
				ns_m1 = `ReadData;
			end
			else begin
				ns_m1 = `ReadAddr;
			end
		end
		`ReadData:begin
			if(RLAST_M1 && RREADY_M1 && RVALID_M1)begin
				ns_m1 = `Idle;
			end
			else begin
				ns_m1 = `ReadData;
			end
		end
		`WriteAddr:begin
			if(AWVALID_M1 && AWREADY_M1)begin
				ns_m1 = `WriteData;
			end
			else begin
				ns_m1 = `WriteAddr;
			end
		end
		`WriteData:begin
			if(WLAST_M1 && WVALID_M1 && WREADY_M1)begin
				ns_m1 = `WriteResp;
			end
			else begin
				ns_m1 = `WriteData;
			end
		end
		`WriteResp:begin
			if(BVALID_M1 && BREADY_M1)begin
				ns_m1 = `Idle;
			end
			else begin
				ns_m1 = `WriteResp;		
			end
		end
		default:begin
			ns_m1 = `Idle;
		end
	endcase
end


///-------------M1 read address(DM)-------------///
always@(*)begin
	if(ARVALID_M1)begin
		ARID_M1 = 4'd1;
		ARLEN_M1 = 4'd0;
		ARSIZE_M1 = 3'd2;
		ARBURST_M1 = 2'd1;
	end
	else begin
		ARID_M1 = 4'd0;
		ARLEN_M1 = 4'd0;
		ARSIZE_M1 = 3'd0;
		ARBURST_M1 = 2'd0;
	end
end


always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARVALID_M1 <= 1'b0;
	end
	else if(ARVALID_M1 && ARREADY_M1)begin
		ARVALID_M1 <= 1'b0;
	end
	else if((cs_m1 == `Idle) && (~D_write) && D_req)begin
		ARVALID_M1 <= 1'b1;
	end
end


always@(*)begin
	if(ARVALID_M1)begin
		ARADDR_M1 = D_addr;
	end
	else begin
		ARADDR_M1 = 32'd0;
	end
end


/*
always@(*)begin
	if(cs_m1 == `ReadAddr)begin
		ARVALID_M1 = 1'b1;
	end
	else begin
		ARVALID_M1 = 1'b0;
	end
end
*/


/*
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARADDR_M1 <= 32'd0;
	end
	else if(ARVALID_M1)begin
		ARADDR_M1 <= ARADDR_M1;
	end
	else begin
		//ARADDR_M1 <= DM_addr;
		ARADDR_M1 <= D_addr;
	end
end
*/






///-------------M1 read data(IM)-------------///
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		RREADY_M1 <= 1'b0;
	end
	else if(RREADY_M1)begin
		RREADY_M1 <= 1'b0;
	end
	else if(~RREADY_M1 && RVALID_M1)begin
		RREADY_M1 <= 1'b1;
	end
end

always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		DM_output <= 32'd0;
	end
	else if(RREADY_M1 && RVALID_M1)begin
		DM_output <= RDATA_M1;
	end
end


///-------------M1 write address(DM)-------------///


always@(*)begin
	if(AWVALID_M1)begin
		AWID_M1 = 4'd1;
		AWLEN_M1 = 4'd0;
		AWSIZE_M1 = 3'd2;
		AWBURST_M1 = 2'd1;
	end
	else begin
		AWID_M1 = 4'd0;
		AWLEN_M1 = 4'd0;
		AWSIZE_M1 = 3'd0;
		AWBURST_M1 = 2'd0;
	end
end
/*
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		AWVALID_M1 <= 1'b0;
	end
	else if(AWVALID_M1 && AWREADY_M1)begin
		AWVALID_M1 <= 1'b0;
	end
	else if((cs_m1 == `Idle) && DM_Read)begin
		AWVALID_M1 <= 1'b1;
	end
end
*/
/*
always@(*)begin
	if(cs_m1 == `WriteAddr)begin
		AWVALID_M1 = 1'b1;
	end
	else begin
		AWVALID_M1 = 1'b0;
	end
end
*/

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		AWVALID_M1	<= 1'b0;
	end
	else if((cs_m1 == `Idle) && (D_write) && (D_req)) begin
		AWVALID_M1	<= 1'b1;
	end
	else if(AWVALID_M1 && AWREADY_M1) begin
		AWVALID_M1	<= 1'b0;
	end
end


always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		AWADDR_M1 <= 32'd0;
	end
	else if(AWVALID_M1)begin
		AWADDR_M1 <= AWADDR_M1;
	end
	else begin
		//AWADDR_M1 <= DM_addr;
		AWADDR_M1 <= D_addr;
	end
end

///-------------M1 write data(DM)-------------///

always@(*)begin
	if(cs_m1 == `WriteData)begin
		WVALID_M1 = 1'b1;
		//WDATA_M1 = DM_input;
		WDATA_M1 = D_in;
		WSTRB_M1 = DM_WEB;
		WLAST_M1 = 1'b1;
	end
	else begin
		WVALID_M1 = 1'b0;
		WDATA_M1 = 32'd0;
		WSTRB_M1 = 4'b1111;
		WLAST_M1 = 1'b0;
	end
end
///-------------M1 write response(DM)-------------///
always@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		BREADY_M1 <= 1'b0;
	end
	else if(BVALID_M1 && ~BREADY_M1)begin
		BREADY_M1 <= 1'b1;
	end
	else if(BREADY_M1)begin
		BREADY_M1 <= 1'b0;
	end
	else begin
		BREADY_M1 <= BREADY_M1;
	end
end
/*
always@(*)begin
	if((cs_m1 == `WriteData) || (cs_m1 == `WriteResp))begin
		BREADY_M1 = 1'b1;
	end
	else begin
		BREADY_M1 = 1'b0;
	end
end
*/

///-------------CPU stall-------------///
/*always@(*)begin
	if((cs_m0 == `Idle) && (cs_m1 == `Idle))begin
		CPU_Ready = 1'b1;
	end
	else begin
		CPU_Ready = 1'b0;
	end
end*/



always@(*)begin
	if(~DM_wait && ~IM_wait)begin
		CPU_Ready = 1'b1;
	end
	else begin
		CPU_Ready = 1'b0;
	end
end

endmodule
