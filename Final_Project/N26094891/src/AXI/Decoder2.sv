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

module Decoder2 (
  input logic ACLK,
  input logic ARESETn,
  input logic [5:0]CS_R,
  input logic [5:0]CS_W, 
  input logic [5:0]NS_R,
  input logic [5:0]NS_W, 
  input logic [`AXI_IDS_BITS-1:0]  RID   ,
  input logic [`AXI_DATA_BITS-1:0] RDATA ,
  input logic [1:0]                RRESP ,
  input logic                      RLAST ,
  input logic                      RVALID,
  input logic [`AXI_IDS_BITS-1:0] BID   ,
  input logic [1:0]               BRESP ,
  input logic                     BVALID, 
  input logic AWREADY,
  input logic WREADY,
  input logic ARREADY,
  input logic RREADY,
  output logic[`AXI_ID_BITS-1:0]   RID_M0   ,
  output logic[`AXI_DATA_BITS-1:0] RDATA_M0 ,
  output logic[1:0]                RRESP_M0 ,
  output logic                     RLAST_M0 ,
  output logic                     RVALID_M0, 
  output logic[`AXI_ID_BITS-1:0]   RID_M1   ,
  output logic[`AXI_DATA_BITS-1:0] RDATA_M1 ,
  output logic[1:0]                RRESP_M1 ,
  output logic                     RLAST_M1 ,
  output logic                     RVALID_M1, 
 
  output logic[`AXI_ID_BITS-1:0] BID_M0   ,    
  output logic[1:0]              BRESP_M0 , 
  output logic[`AXI_ID_BITS-1:0] BID_M1   ,    
  output logic[1:0]              BRESP_M1 ,
  output logic                   BVALID_M1,
  output logic  ARREADY_M0  ,
  output logic  AWREADY_M1  ,
  output logic  WREADY_M1   ,
  output logic  ARREADY_M1
);



logic [3: 0] ARLEN_cnt;
always@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		ARLEN_cnt <= 4'd0;
	end
	else if(CS_R ==`READ_DATA_M1S0 ||CS_R ==`READ_DATA_M1S1 ||CS_R ==`READ_DATA_M0S0 ||CS_R ==`READ_DATA_M0S1) begin
		if(RVALID && RREADY) begin
			ARLEN_cnt <= ARLEN_cnt + 4'd1;
		end
		else begin
			ARLEN_cnt <= ARLEN_cnt;
		end	
	end
	else begin
		ARLEN_cnt <= 4'd0;
	end	

end

//R decoder//jjhu
always_comb begin
  case(CS_R)
    `READ_DATA_M0S0:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt) ) begin
	 	RLAST_M0 = RLAST     ;
	 end
	 else begin 
	 	RLAST_M0	= 1'd0      ;
	 end*/
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID     ;        
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end
    `READ_DATA_M0S1:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt)) begin
	 	RLAST_M0 = RLAST;
	 end
	 else begin 
	 	RLAST_M0 = 1'd0;
	 end*/
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID    ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end	
	`READ_DATA_M0S2:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt)) begin
	 	RLAST_M0 = RLAST;
	 end
	 else begin 
	 	RLAST_M0 = 1'd0;
	 end*/
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID    ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end	
	`READ_DATA_M0S3:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID    ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end	
	`READ_DATA_M0S4:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt)) begin
	 	RLAST_M0 = RLAST;
	 end
	 else begin 
	 	RLAST_M0 = 1'd0;
	 end*/
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID    ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end	

	`READ_DATA_M0S5:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 RLAST_M0 = RLAST     ;
	 RVALID_M0    = RVALID    ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end	

	`READ_DATA_M1S0:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt)) begin
	 	RLAST_M1 = RLAST;
	 end
	 else begin 
	 	RLAST_M1 = 1'd0;
	 end*/
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;        
    end
	`READ_DATA_M1S1:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt) ) begin
		RLAST_M1 = RLAST;
	 end
	 else begin 
	 	RLAST_M1 = 1'd0;
	 end */
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;         
    end	
	`READ_DATA_M1S2:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt) ) begin
		RLAST_M1 = RLAST;
	 end
	 else begin 
	 	RLAST_M1 = 1'd0;
	 end */
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;         
    end	
	`READ_DATA_M1S3:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;         
    end	
	`READ_DATA_M1S4:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt) ) begin
		RLAST_M1 = RLAST;
	 end
	 else begin 
	 	RLAST_M1 = 1'd0;
	 end */
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;         
    end	
	`READ_DATA_M1S5:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 //Burst mode execution
	 /*if((ARLEN == ARLEN_cnt) ) begin
		RLAST_M1 = RLAST;
	 end
	 else begin 
	 	RLAST_M1 = 1'd0;
	 end */
	 RLAST_M1 = RLAST;
	 RVALID_M1    = RVALID     ;         
    end		
	
	/*`READ_AR_R_M0S0||`READ_AR_R_M0S1:begin
	 RID_M0       = RID[3:0]   ;
	 RDATA_M0     = RDATA      ;
	 RRESP_M0     = RRESP      ;
	 RLAST_M0     = RLAST      ;
	 RVALID_M0    = RVALID     ;         
	 RID_M1       = 4'd0      ;
	 RDATA_M1     = 32'd0     ;
	 RRESP_M1     = 2'd0      ;
	 RLAST_M1     = 1'd0      ;
	 RVALID_M1    = 1'd0      ;
	end
	`READ_AR_R_M1S0||`READ_AR_R_M1S1:begin
	 RID_M0       = 4'd0      ;
	 RDATA_M0     = 32'd0     ;
	 RRESP_M0     = 2'd0      ;
	 RLAST_M0     = 1'd0      ;
	 RVALID_M0    = 1'd0      ;
	 RID_M1       = RID[3:0]   ;
	 RDATA_M1     = RDATA      ;
	 RRESP_M1     = RRESP      ;
	 RLAST_M1     = RLAST      ;
	 RVALID_M1    = RVALID     ;   

	end*/

	default:begin
	 RID_M0       = 4'd0           ;
	 RDATA_M0     = 32'd0          ;
	 RRESP_M0     = 2'd0           ;
	 RLAST_M0     = 1'd0           ;
	 RVALID_M0    = 1'd0           ;	
	 RID_M1       = 4'd0           ;
	 RDATA_M1     = 32'd0          ;
	 RRESP_M1     = 2'd0           ;
	 RLAST_M1     = 1'd0           ;
	 RVALID_M1    = 1'd0           ;	
	end
  endcase
end

//B decoder
always_comb begin
  case(CS_W)
	`WRITE_B_M1S0:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end
	`WRITE_B_M1S1:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end	
	`WRITE_B_M1S2:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end	
	`WRITE_B_M1S3:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end	
	`WRITE_B_M1S4:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end	
	`WRITE_B_M1S5:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end		
	
	default:begin
	  BID_M0     = 4'd0    ;
	  BRESP_M0   = 2'd0    ;
	  //BVALID_M0  = 1'd0    ;
	  BID_M1     = 4'd0    ;
	  BRESP_M1   = 2'd0    ;
	  BVALID_M1  = 1'd0    ;	
	end
  endcase
end

//AWRWEADY
always_comb begin
  case(CS_W)
    `WRITE_ADDR_M0:begin
      //AWREADY_M0 = AWREADY ;
	  AWREADY_M1 = 1'd0 ;
	end
	`WRITE_ADDR_M1:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S0:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S1:begin
     // AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S2:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S3:begin
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S4:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`WRITE_M1_SIM_S5:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end	
	
	default:begin
      //AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = 1'd0 ;	
	end
  endcase
end
//WREADY
always_comb begin
  case(CS_W)
	`WRITE_DATA_M1S0:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end
	`WRITE_DATA_M1S1:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_DATA_M1S2:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_DATA_M1S3:begin
      WREADY_M1 = WREADY ;
    end	
	`WRITE_DATA_M1S4:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_DATA_M1S5:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end		
	`WRITE_M1_SIM_S0:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end
	`WRITE_M1_SIM_S1:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_M1_SIM_S2:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_M1_SIM_S3:begin
      WREADY_M1 = WREADY ;
    end	
	`WRITE_M1_SIM_S4:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`WRITE_M1_SIM_S5:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end		
	default:begin
      //WREADY_M0 = 1'd0 ;
      WREADY_M1 = 1'd0 ;	
	end
  endcase
end
//ARREADY 
always_comb
begin
  case(CS_R)
    `READ_ADDR_M0:begin
      ARREADY_M0 = ARREADY ;
	  ARREADY_M1 = 1'd0 ;
	end
	`READ_ADDR_M1:begin
      ARREADY_M0 = 1'd0 ;
	  ARREADY_M1 = ARREADY ;
    end
	default:begin
      ARREADY_M0 = 1'd0 ;
	  ARREADY_M1 = 1'd0 ;	
	end
  endcase
end


endmodule 
