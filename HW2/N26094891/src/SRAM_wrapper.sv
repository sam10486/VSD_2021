`include "../include/AXI_define.svh"
`define IDLE    3'b000
`define RAddr 	3'b001
`define RData 	3'b010
`define WAddr 	3'b011
`define WData  	3'b100
`define WResp  	3'b101

module SRAM_wrapper (
	input ACLK,
	input ARESETn,
	
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S,
	input AWVALID_S,
	output logic AWREADY_S,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input WLAST_S,
	input WVALID_S,
	output logic WREADY_S,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input BREADY_S,
	
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S
);

//SRAM declare
logic 						OE,chipsel;
logic	[3:0] 					WEB;
logic	[13:0] 					A;
logic	[31:0] 					DI;
logic	[31:0] 					DO;

logic	[2:0]					cs,ns;

logic	[`AXI_IDS_BITS-1:0]		reg_arid;
logic	[`AXI_ADDR_BITS-1:0]	reg_araddr,reg_araddr_4;
logic	[`AXI_LEN_BITS-1:0]		reg_arlen;
logic	[3:0]					count_r;
//logic 	[31:0]					reg_DO;
//logic 	[31:0]					DO_;

logic	[`AXI_IDS_BITS-1:0]		reg_awid;
logic	[`AXI_ADDR_BITS-1:0]	reg_awaddr;
logic	[`AXI_LEN_BITS-1:0]		reg_awlen;
logic	[3:0]					count_w;

logic							a_flag;


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
			if(ARVALID_S)
				ns = `RAddr;
			else if(AWVALID_S)
				ns = `WAddr;
			else
				ns = `IDLE;
		end
		`RAddr: begin
			if(ARVALID_S && ARREADY_S)
				ns = `RData;
			else
				ns = `RAddr;
		end
		`RData: begin
			if(RLAST_S && RREADY_S && RVALID_S)
				ns = `IDLE;
			else
				ns = `RData;
		end
		`WAddr: begin
			if(AWVALID_S && AWREADY_S)
				ns = `WData;
			else
				ns = `WAddr;
		end
		`WData: begin
			if(WVALID_S && WREADY_S && WLAST_S)
				ns = `WResp;
			else
				ns = `WData;
		end
		`WResp: begin
			if(BVALID_S && BREADY_S)
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
always_comb begin
	if(cs == `RAddr) begin
		ARREADY_S = 1'b1;
	end
	else begin
		ARREADY_S = 1'b0;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		reg_arid 	<= 8'd0;
		//reg_araddr 	<= 32'd0;
		reg_araddr_4<= 32'd0;
		reg_arlen 	<= 4'd0;
	end
	else if(cs == `IDLE) begin
		reg_arid 	<= ARID_S;
		//reg_araddr 	<= ARADDR_S;
		reg_araddr_4<= ARADDR_S+32'd4;
		reg_arlen 	<= ARLEN_S;
	end
	else if(cs == `RData) begin
		reg_arid 	<= reg_arid;
		//reg_araddr 	<= reg_araddr;
		reg_araddr_4<= reg_araddr_4;
		reg_arlen 	<= reg_arlen;
	end
/*
	else begin
		reg_arid 	<= 8'd0;
		reg_araddr 	<= 32'd0;
		reg_araddr_4<= 32'd0;
		reg_arlen 	<= 4'd0;
	end
*/
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		count_r <= 4'd0;
	end
	else if(cs == `RData && RREADY_S && RVALID_S) begin
		count_r <= count_r + 4'd1;
	end
	else if(cs == `IDLE) begin
		count_r <= 4'd0;
	end
end


always_comb begin
	if(cs == `RData) begin
		if((count_r) == (reg_arlen)) begin
			RID_S		= reg_arid;
			RDATA_S		= DO;
			RRESP_S		= 2'b11;
			RLAST_S		= 1'b1;
			//RVALID_S	= 1'b1;	
		end
		else begin
			RID_S		= reg_arid;
			RDATA_S		= DO;
			RRESP_S		= 2'd0;
			RLAST_S		= 1'b0;
			//RVALID_S	= 1'b1;
		end
	end
	else begin
		RID_S		= 8'd0;
		RDATA_S		= 32'd0;
		RRESP_S		= 2'd0;
		RLAST_S		= 1'b0;
		//RVALID_S	= 1'b0;
	end
end

/*
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		reg_DO	<= 32'd0;
	end
	else if(RREADY_S) begin
		reg_DO	<= DO;
	end
	else begin
		reg_DO <= reg_DO;
	end
end
*/

/*
always_ff @(posedge RREADY_S or posedge ARVALID_S) begin
	if(cs == `RData) begin
		if(RVALID_S) begin
			a_flag <= 1'b1; 
		end
		else begin
			a_flag <= 1'b0;
		end
	end
	else begin
		a_flag <= 1'b0;
	end
end
*/

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		RVALID_S 	<= 1'b0;
		reg_araddr 	<= 32'd0;
	end
	else if(cs == `IDLE) begin
		RVALID_S 	<= 1'b0;
		reg_araddr 	<= ARADDR_S;
	end
	else if(cs == `RData) begin
		if(RREADY_S && RVALID_S) begin
			RVALID_S 	<= 1'b0;
			reg_araddr 	<= reg_araddr + 32'd4;
		end
		else if(~RVALID_S) begin
			RVALID_S 	<= 1'b1;
			reg_araddr 	<= reg_araddr;
		end
	end
	else begin
		RVALID_S 	<= 1'b0;
		reg_araddr 	<= reg_araddr;
	end
end

//assign a_flag = RVALID_S && (RREADY_S ^ RLAST_S);

//assign DO_ = (RREADY_S && RVALID_S)?DO:reg_DO;

//SRAM Signal
always_comb begin
	case(cs)
		`IDLE: begin
			A	= 14'd0;
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b0;
			chipsel	= 1'b0;
		end
		`RAddr: begin
			A	= ARADDR_S[15:2];
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b0;
			chipsel	= 1'b1;
		end
		`RData: begin
			A	= reg_araddr[15:2];
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b1;
			chipsel	= 1'b1;
		end
		`WAddr: begin
			A	= 14'd0;
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b0;
			chipsel	= 1'b0;
		end
		`WData: begin
			A	= reg_awaddr[15:2] + {{10'b0},count_w};
			DI 	= WDATA_S;
			WEB	= WSTRB_S;
			OE	= 1'b0;
			chipsel	= 1'b1;
		end
		`WResp: begin
			A	= 14'd0;
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b0;
			chipsel	= 1'b0;
		end
		default: begin
			A	= 14'd0;
			DI 	= 32'd0;
			WEB	= 4'b1111;
			OE	= 1'b0;
			chipsel	= 1'b0;
		end
	endcase
end

//WRITE CHANNEL
always_comb begin
	if(cs == `WAddr) begin
		AWREADY_S = 1'b1;
	end
	else begin
		AWREADY_S = 1'b0;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		reg_awid 	<= 8'd0;
		reg_awaddr 	<= 32'd0;
		reg_awlen 	<= 4'd0;
	end
	else if(cs == `WAddr) begin
		reg_awid 	<= AWID_S;
		reg_awaddr 	<= AWADDR_S;
		reg_awlen 	<= AWLEN_S;
	end
	else if(cs==`WData || cs==`WResp) begin
		reg_awid 	<= reg_awid;
		reg_awaddr 	<= reg_awaddr;
		reg_awlen 	<= reg_awlen;
	end
	else begin
		reg_awid 	<= 8'd0;
		reg_awaddr 	<= 32'd0;
		reg_awlen 	<= 4'd0;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		count_w <= 4'd0;
	end
	else if(cs == `WData && WVALID_S) begin
		count_w <= count_w + 4'd1;
	end
	else if(cs == `IDLE) begin
		count_w <= 4'd0;
	end
end

always_comb begin
	if(cs == `WData) begin
		WREADY_S = 1'b1;
	end
	else begin
		WREADY_S = 1'b0;
	end
end

always_comb begin
	if(cs == `WResp) begin
		BID_S		= reg_awid;
		BRESP_S		= 2'b00;
		BVALID_S	= 1'b1;
	end
	else begin
		BID_S		= 8'b0;
		BRESP_S		= 2'b11;
		BVALID_S	= 1'b0;
	end
end



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
    .CK   (ACLK    ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (chipsel    )
  );

endmodule

