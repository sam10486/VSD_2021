`include "../../include/AXI_define.svh"
/*`define IDLE              5'b00000
`define READ_ADDR_M1       5'b00001
`define READ_DATA_M1S0     5'b00010
`define READ_DATA_M1S1     5'b00011
`define READ_ADDR_M0       5'b00100
`define READ_DATA_M0S0     5'b00101
`define READ_DATA_M0S1     5'b00110
`define WRITE_ADDR_M1      5'b00111
`define WRITE_DATA_M1S0    5'b01000
`define WRITE_DATA_M1S1    5'b01001
`define WRITE_B_M1S0    5'b01010
`define WRITE_B_M1S1    5'b01011
`define WRITE_ADDR_M0      5'b01100
`define default_slave     5'b01101
`define WRITE_M1_SIM_S0 5'b01110
`define WRITE_M1_SIM_S1 5'b01111
`define READ_AR_R_M0S0       5'b10000
`define READ_AR_R_M0S1       5'b10001
`define READ_AR_R_M1S0       5'b10010
`define READ_AR_R_M1S1       5'b10011
*/
`define IDLE              6'b000000
`define READ_ADDR_M1       6'b000001
`define READ_DATA_M1S0     6'b000010
`define READ_DATA_M1S1     6'b000011
`define READ_ADDR_M0       6'b000100
`define READ_DATA_M0S0     6'b000101
`define READ_DATA_M0S1     6'b000110
`define WRITE_ADDR_M1      6'b000111
`define WRITE_DATA_M1S0    6'b001000
`define WRITE_DATA_M1S1    6'b001001
`define WRITE_B_M1S0       6'b001010
`define WRITE_B_M1S1       6'b001011
`define WRITE_ADDR_M0      6'b001100
`define default_slave     6'b001101
`define WRITE_M1_SIM_S0    6'b001110
`define WRITE_M1_SIM_S1    6'b001111
//adding new states of slave 2, 3, 4
`define READ_DATA_M1S2 6'b010000
`define READ_DATA_M1S3 6'b010001
`define READ_DATA_M1S4 6'b010010
`define READ_DATA_M0S2 6'b010011
`define READ_DATA_M0S3 6'b010100
`define READ_DATA_M0S4 6'b010101
`define WRITE_DATA_M1S2 6'b011000
`define WRITE_DATA_M1S3 6'b011001
`define WRITE_DATA_M1S4 6'b011010
`define WRITE_B_M1S2 6'b011011
`define WRITE_B_M1S3 6'b011100
`define WRITE_B_M1S4 6'b011101
`define WRITE_M1_SIM_S2    6'b011110
`define WRITE_M1_SIM_S3    6'b011111
`define WRITE_M1_SIM_S4    6'b010110
//adding new states of slave 5
`define READ_DATA_M1S5 6'b100000
`define READ_DATA_M0S5 6'b100001
`define WRITE_DATA_M1S5 6'b100010
`define WRITE_B_M1S5 6'b100011
`define WRITE_M1_SIM_S5 6'b100100

module Mux1(
    input logic ACLK,
	input logic ARESETn,
	input logic [5:0]CS_R,
	input logic [5:0]CS_W, 
	input logic [5:0]NS_R,
	input logic [5:0]NS_W,              
	input logic [`AXI_ID_BITS-1:0]   AWID_M0   ,  
	input logic [`AXI_ADDR_BITS-1:0] AWADDR_M0 ,
	input logic [`AXI_LEN_BITS-1:0]  AWLEN_M0  , 
	input logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0 ,
	input logic [1:0]                AWBURST_M0,
	input logic                      AWVALID_M0,  
	input logic [`AXI_ID_BITS-1:0]   AWID_M1   ,  
	input logic [`AXI_ADDR_BITS-1:0] AWADDR_M1 ,
	input logic [`AXI_LEN_BITS-1:0]  AWLEN_M1  , 
	input logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1 ,
	input logic [1:0]                AWBURST_M1,
	input logic                      AWVALID_M1,  
	input logic [`AXI_ID_BITS-1:0]   ARID_M0   ,     
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_M0 , 
	input logic [`AXI_LEN_BITS-1:0]  ARLEN_M0  ,   
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0 , 
	input logic [1:0]                ARBURST_M0,
	input logic                      ARVALID_M0,	
	input logic [`AXI_ID_BITS-1:0]   ARID_M1   ,     
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_M1 , 
	input logic [`AXI_LEN_BITS-1:0]  ARLEN_M1  ,   
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1 , 
	input logic [1:0]                ARBURST_M1,
	input logic                      ARVALID_M1,
	input logic [`AXI_DATA_BITS-1:0] WDATA_M0  ,  
	input logic [`AXI_STRB_BITS-1:0] WSTRB_M0  ,  
	input logic                      WLAST_M0  ,
	input logic                      WVALID_M0 ,		
	input logic [`AXI_DATA_BITS-1:0] WDATA_M1  ,  
	input logic [`AXI_STRB_BITS-1:0] WSTRB_M1  ,  
	input logic                      WLAST_M1  ,
	input logic                      WVALID_M1  ,	   	

    input RREADY_M0,
	input RREADY_M1,
    input BREADY_M0,
	input BREADY_M1,
    input ARREADY,
    input AWREADY,

	output logic[`AXI_ID_BITS-1:0]   AWID   ,  
	output logic[`AXI_ADDR_BITS-1:0] AWADDR ,
	output logic[`AXI_LEN_BITS-1:0]  AWLEN  , 
	output logic[`AXI_SIZE_BITS-1:0] AWSIZE ,
	output logic[1:0]                AWBURST,
	output logic                     AWVALID, 	

	output logic[`AXI_DATA_BITS-1:0] WDATA   ,  
	output logic[`AXI_STRB_BITS-1:0] WSTRB   ,  
	output logic                     WLAST   ,
	output logic                     WVALID  ,	
  	
	output logic[`AXI_ID_BITS-1:0]   ARID    ,     
	output logic[`AXI_ADDR_BITS-1:0] ARADDR  , 
	output logic[`AXI_LEN_BITS-1:0]  ARLEN   ,   
	output logic[`AXI_SIZE_BITS-1:0] ARSIZE  , 
	output logic[1:0]                ARBURST ,
	output logic                     ARVALID ,
	output logic RREADY,
    output logic BREADY	
);

//AW
always_comb begin
		  case(CS_W)
		  	`WRITE_ADDR_M0:begin
				  AWID      =    AWID_M0     ;
				  AWADDR    =    AWADDR_M0   ;
				  AWLEN     =    AWLEN_M0    ;
				  AWSIZE    =    AWSIZE_M0   ;
				  AWBURST   =    AWBURST_M0  ;
				  AWVALID   =    AWVALID_M0  ;

			end
			`WRITE_ADDR_M1:begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;	
			end
                  	`WRITE_M1_SIM_S0 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  	`WRITE_M1_SIM_S1 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  	`WRITE_M1_SIM_S2 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  	`WRITE_M1_SIM_S3 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  	`WRITE_M1_SIM_S4 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  	`WRITE_M1_SIM_S5 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end		
			default:begin
			  AWID      =    4'd0            ;
			  AWADDR    =    32'd0           ;
			  AWLEN     =    4'd0            ;
			  AWSIZE    =    3'd0            ;
			  AWBURST   =    2'd0            ;
			  AWVALID   =    1'd0            ;	  
			end
		  endcase

end

//W
always_comb begin
		  case(CS_W)
		    `WRITE_DATA_M1S0 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_DATA_M1S1:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_DATA_M1S2:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_DATA_M1S3:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_DATA_M1S4:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_DATA_M1S5:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end			
		    `WRITE_M1_SIM_S0:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                           
			end
		    `WRITE_M1_SIM_S1:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                          
			end
		    `WRITE_M1_SIM_S2:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                          
			end
		    `WRITE_M1_SIM_S3:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                          
			end
		    `WRITE_M1_SIM_S4:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                          
			end
		    `WRITE_M1_SIM_S5:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                          
			end
			
			default:begin
			  WDATA    =  32'd0             ;
			  WSTRB    =  4'd0              ;
			  WLAST    =  1'd0              ;
			  WVALID   =  1'd0              ;
			end
		  endcase
end

//keep the ARLEN to the READ DATA state M0
logic [3:0] ARLEN_M0_current;
logic [3:0] ARLEN_M1_current;
//logic [3:0] ARLEN_M0_tmp;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
	ARLEN_M0_current <= 4'd0;
    end
    else if(CS_R == `READ_ADDR_M0 || CS_R == `READ_ADDR_M1) begin
	if(ARVALID_M0)
	ARLEN_M0_current <= ARLEN_M0;
    end
    else if(CS_R == `READ_DATA_M0S0 || CS_R == `READ_DATA_M1S0 || CS_R == `READ_DATA_M0S1 || CS_R == `READ_DATA_M1S1) begin
	ARLEN_M0_current <=  ARLEN_M0_current ;
    end
    else begin
    	ARLEN_M0_current <= 4'd0;
    end 
end

always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
	ARLEN_M1_current <= 4'd0;
    end
    else if(CS_R == `READ_ADDR_M0 || CS_R == `READ_ADDR_M1) begin
	if(ARVALID_M1)
	ARLEN_M1_current <= ARLEN_M1;
    end
    else if(CS_R == `READ_DATA_M0S0 || CS_R == `READ_DATA_M1S0 || CS_R == `READ_DATA_M0S1 || CS_R == `READ_DATA_M1S1) begin
	ARLEN_M1_current <=  ARLEN_M1_current ;
    end
    else begin
    	ARLEN_M1_current <= 4'd0;
    end 
end
/*
always_comb begin
	if ((ARVALID_M0 ==1'd1))  ARLEN_M0_current = ARLEN_M0;
	//else if(RREADY_M0 && (ARLEN_M0>4'd0)) ARLEN_M0_current =  ARLEN_M0 - 4'b0001;
        else ARLEN_M0_current = ARLEN_M0_tmp;
end*/

//keep the ARLEN to the READ DATA state M1
/*
logic [3:0] ARLEN_M1_current;
logic [3:0] ARLEN_M1_tmp;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
	ARLEN_M1_current <= 4'd0;
	ARLEN_M1_tmp <= 4'd0;
    end
    else begin
         ARLEN_M1_tmp <= ARLEN_M1_current;
    end
end
always_comb begin
	if ((ARVALID_M1 ==1'd1))  ARLEN_M1_current = ARLEN_M1;
	//else if(RREADY_M1 && (ARLEN_M1>4'd0)) ARLEN_M1_current =  ARLEN_M1 - 4'b0001;
        else ARLEN_M1_current = ARLEN_M1_tmp;
end
*/



//AR
always_comb begin	 
		  case(CS_R)
		  	`READ_ADDR_M0:begin 
			  ARID     =  ARID_M0         ;
			  ARADDR   =  ARADDR_M0       ;
			  //if(ARLEN_M0>4'b0000 && (ARVALID_M0) &&(ARREADY_M0)) ARLEN_M0 = 4'b0000;
			  ARLEN    =  ARLEN_M0        ;
			  ARSIZE   =  ARSIZE_M0       ;
			  ARBURST  =  ARBURST_M0      ;
			  ARVALID  =  ARVALID_M0      ;
			  end
			`READ_ADDR_M1:begin
			  ARID     =  ARID_M1         ;
			  ARADDR   =  ARADDR_M1       ;
			  //if(ARLEN_M1==4'b0001) ARLEN_M1 = 4'b0000;
			  ARLEN    =  ARLEN_M1        ;
			  ARSIZE   =  ARSIZE_M1       ;
			  ARBURST  =  ARBURST_M1      ;
			  ARVALID  =  ARVALID_M1      ;
			  end		
                       	 /*`READ_DATA_M0S0:begin
			 	
				ARLEN = ARLEN_M0_current ;
			 	ARVALID = 1'd0; 
			 end
                       	 `READ_DATA_M0S1:begin
			 	
				ARLEN = ARLEN_M0_current ;
				ARVALID = 1'd0; 
			 end
                       	 `READ_DATA_M1S0:begin
			 	
				ARLEN = ARLEN_M1_current ;
				ARVALID = 1'd0; 
			 end
                       	 `READ_DATA_M1S1:begin
			 	
				ARLEN = ARLEN_M1_current ;
				ARVALID = 1'd0; 
			 end
				*/
			 default:begin
			 	ARID     =  4'd0               ;
			 	ARADDR   =  32'd0              ;
			 	ARLEN    =  4'd0               ;
			 	ARSIZE   =  3'd0               ;
				ARBURST  =  2'd0               ;
			 	ARVALID  =  1'd0               ;
			 end
		  endcase
end


//RWREADY
always_comb
begin
  case(CS_R)
    `READ_DATA_M0S0 :begin                  
      RREADY = RREADY_M0 ;
	end
    `READ_DATA_M0S1:begin                  
      RREADY = RREADY_M0 ;
	end	
    `READ_DATA_M0S2:begin                  
      RREADY = RREADY_M0 ;
	end
    `READ_DATA_M0S3:begin                  
      RREADY = RREADY_M0 ;
	end
    `READ_DATA_M0S4:begin                  
      RREADY = RREADY_M0 ;
	end
    `READ_DATA_M0S5:begin                  
      RREADY = RREADY_M0 ;
	end
	
	`READ_DATA_M1S0 :begin
      RREADY = RREADY_M1 ;
	end
	`READ_DATA_M1S1:begin
      RREADY = RREADY_M1 ;
	end	
	`READ_DATA_M1S2:begin
      RREADY = RREADY_M1 ;
	end
	`READ_DATA_M1S3:begin
      RREADY = RREADY_M1 ;
	end
	`READ_DATA_M1S4:begin
      RREADY = RREADY_M1 ;
	end
	`READ_DATA_M1S5:begin
      RREADY = RREADY_M1 ;
	end
	/*`READ_AR_R_M0S0||`READ_AR_R_M0S1:begin
	RREADY = RREADY_M0 ;
	end
	`READ_AR_R_M1S0||`READ_AR_R_M1S1:begin
	RREADY = RREADY_M1 ;
	end*/
	default:begin
      RREADY = 1'd0 ;
	end
  endcase
end

//BREADY
always_comb begin
  case(CS_W)
    `WRITE_B_M1S0:begin                  
      BREADY = BREADY_M1 ;
	end
    `WRITE_B_M1S1:begin                  
      BREADY = BREADY_M1 ;
	end	
    `WRITE_B_M1S2:begin                  
      BREADY = BREADY_M1 ;
	end
    `WRITE_B_M1S3:begin                  
      BREADY = BREADY_M1 ;
	end
    `WRITE_B_M1S4:begin                  
      BREADY = BREADY_M1 ;
	end
    `WRITE_B_M1S5:begin                  
      BREADY = BREADY_M1 ;
	end
	default:begin
      BREADY = 1'd0 ;
	end
  endcase
end


endmodule


















