`include "../../include/AXI_define.svh"
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

/*`define READ_AR_R_M0S0       5'b10000
`define READ_AR_R_M0S1       5'b10001
`define READ_AR_R_M1S0       5'b10010
`define READ_AR_R_M1S1       5'b10011
*/
module Arbiter (
	input logic ACLK,
	input logic ARESETn, 
	input logic AWVALID_M0,	
	input logic ARVALID_M0,
	input logic ARREADY_M0,	
	input logic AWVALID_M1,
	input logic AWREADY_M1,
	input logic WVALID_M1,
	input logic WREADY_M1,
	input logic BVALID_M1,
	input logic BREADY_M1,
	input logic ARVALID_M1,
	input logic ARREADY_M1,	
	input logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input logic RVALID_M0,
	input logic RVALID_M1,
	input logic RREADY_M0,	
	input logic RREADY_M1,	
	input logic WLAST_M1,
	input logic RLAST_M1,
	input logic RLAST_M0,
	
	
	output logic [5:0] CS_R,
	output logic [5:0] CS_W,
	output logic [5:0] NS_R,
	output logic [5:0] NS_W


);


//jjhu
/*logic [31:0] AWADDR_current;
logic [31:0] AWADDR_tmp;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) AWADDR_current <= 32'd0;
    else begin
         AWADDR_tmp <= AWADDR_current;
    end
end
always_comb begin
	if (AWVALID_M1==1'd1)  AWADDR_current = AWADDR_M1;//get new data
        else AWADDR_current = AWADDR_tmp;//keep old data
end*/
//jjhu
always@(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn) begin
		CS_W <= `IDLE;
		CS_R <= `IDLE;
	end
	else begin
		CS_W <= NS_W;
		CS_R <= NS_R;
	end
end
/*
logic [31:0] AWADDR_tmp;
logic [31:0] AWADDR_current;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) AWADDR_current <= 32'd0;
    else begin
         AWADDR_tmp <= AWADDR_current;
    end
end
always_comb begin
	if (AWVALID_M1==1'd1)  AWADDR_current = AWADDR_M1;//get new data
        else AWADDR_current = AWADDR_tmp;//keep old data
end*/
//jjhu
always_comb begin
  case(CS_W)
    `IDLE :begin
	   if(AWVALID_M1 /*&& (AWLEN_M1==4'b0000)*/) begin 
		/*if(WLAST_M1) begin
			if(AWADDR_M1[31:16]==16'd0) begin
				NS_W = `WRITE_M1_SIM_S0; 
		 	end
		 	else if(AWADDR_M1[31:16]==16'd1) begin
				NS_W = `WRITE_M1_SIM_S1;
		 	end 
		 	else begin 
				NS_W = `default_slave;
		 	end
		end
	   	else begin*/
			NS_W = `WRITE_ADDR_M1;
	   	//end
	   end

           /*else if(AWVALID_M0 ) begin
		 NS_W = `WRITE_ADDR_M0; 	   
	   end*/
	   /*else if(AWVALID_M0) begin
		if(AWLEN_M0==4'b0001)
			NS_W = `WRITE_BUSRT_2;
		else if(AWLEN_M0==4'b0010)
			NS_W = `WRITE_BUSRT_4;
	   end*/
           else begin
	   	NS_W = `IDLE; 
	   end                      
	end
    `WRITE_ADDR_M1 :begin
	   if(AWVALID_M1 && AWREADY_M1) begin
	     	/*if(AWADDR_M1[31:16]==16'd0) begin
	     		NS_W = `WRITE_DATA_M1S0; 
	     	end*/
		if((AWADDR_M1[31:0]>=32'h0001_0000)&&(AWADDR_M1[31:0]<=32'h0001_ffff)) begin
	       		NS_W = `WRITE_DATA_M1S1;
		end
		else if(AWADDR_M1[31:16]==16'd2) begin
	       		NS_W = `WRITE_DATA_M1S2;
		end
		else if((AWADDR_M1[31:0]>=32'h1000_0000)&&(AWADDR_M1[31:0]<=32'h1000_03ff)) begin
	       		NS_W = `WRITE_DATA_M1S3;
		end
		else if((AWADDR_M1[31:0]>=32'h2000_0000)&&(AWADDR_M1[31:0]<=32'h207f_ffff)) begin
	       		NS_W = `WRITE_DATA_M1S4;
		end
		else if(AWADDR_M1[31:16]==16'h3000) begin
	       		NS_W = `WRITE_DATA_M1S5;
		end
		else begin 
			NS_W = `default_slave;
		end
	    end
		
		else if(AWVALID_M1 && WVALID_M1)begin
		/*if(AWADDR_M1[31:16]==16'd0) begin
			NS_W = `WRITE_M1_SIM_S0;
		end*/
			if((AWADDR_M1[31:0]>=32'h0001_0000)&&(AWADDR_M1[31:0]<=32'h0001_ffff)) begin
			NS_W = `WRITE_M1_SIM_S1; 
		end
		else if(AWADDR_M1[31:16]==16'd2) begin
			NS_W = `WRITE_M1_SIM_S2; 
		end
		else if((AWADDR_M1[31:0]>=32'h1000_0000)&&(AWADDR_M1[31:0]<=32'h1000_03ff)) begin
			NS_W = `WRITE_M1_SIM_S3; 
		end
		else if((AWADDR_M1[31:0]>=32'h2000_0000)&&(AWADDR_M1[31:0]<=32'h207f_ffff)) begin
			NS_W = `WRITE_M1_SIM_S4; 
		end
		else if(AWADDR_M1[31:16]==16'h3000) begin
			NS_W = `WRITE_M1_SIM_S5;
		end
		else begin
			NS_W = `default_slave;
		end
           end
		   
           else if(AWVALID_M1 && WLAST_M1)begin
		/*if(AWADDR_M1[31:16]==16'd0) begin
			NS_W = `WRITE_M1_SIM_S0;
		end*/
			if((AWADDR_M1[31:0]>=32'h0001_0000)&&(AWADDR_M1[31:0]<=32'h0001_ffff)) begin
			NS_W = `WRITE_M1_SIM_S1; 
		end
		else if(AWADDR_M1[31:16]==16'd2) begin
			NS_W = `WRITE_M1_SIM_S2; 
		end
		else if((AWADDR_M1[31:0]>=32'h1000_0000)&&(AWADDR_M1[31:0]<=32'h1000_03ff)) begin
			NS_W = `WRITE_M1_SIM_S3;
		end
		else if((AWADDR_M1[31:0]>=32'h2000_0000)&&(AWADDR_M1[31:0]<=32'h207f_ffff)) begin
			NS_W = `WRITE_M1_SIM_S4; 
		end 
	  	else if(AWADDR_M1[31:16]==16'h3000) begin
			NS_W = `WRITE_M1_SIM_S5;
		end
		else begin
			NS_W = `default_slave;
		end
           end
	   else begin
			NS_W = `WRITE_ADDR_M1;
	   end
	   end	
    /*`WRITE_DATA_M1S0 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S0;
	  else NS_W = `WRITE_DATA_M1S0;
	end*/
    `WRITE_DATA_M1S1 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S1;
	  else NS_W = `WRITE_DATA_M1S1;
	end		
	`WRITE_DATA_M1S2 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S2;
	  else NS_W = `WRITE_DATA_M1S2;
	end	
	`WRITE_DATA_M1S3 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S3;
	  else NS_W = `WRITE_DATA_M1S3;
	end
	`WRITE_DATA_M1S4 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S4;
	  else NS_W = `WRITE_DATA_M1S4;
	end
	`WRITE_DATA_M1S5 :begin
      if(WVALID_M1 && WREADY_M1 && WLAST_M1) NS_W = `WRITE_B_M1S5;
	  else NS_W = `WRITE_DATA_M1S5;
	end
    /*`WRITE_B_M1S0 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S0;
	end*/	
    `WRITE_B_M1S1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S1;
	end	
	`WRITE_B_M1S2 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S2;
	end	
    `WRITE_B_M1S3 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S3;
	end	
	`WRITE_B_M1S4 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S4;
	end	
	`WRITE_B_M1S5 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WRITE_B_M1S5;
	end	
    /*`WRITE_ADDR_M0 :begin
	   NS_W = `IDLE;
	end*/
    /*`WRITE_M1_SIM_S0 :begin
      if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S0;
	  else NS_W = `WRITE_M1_SIM_S0;
	end*/
    `WRITE_M1_SIM_S1 :begin
        if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S1;
	  else NS_W = `WRITE_M1_SIM_S1;
	end	
    `WRITE_M1_SIM_S2 :begin
        if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S2;
	  else NS_W = `WRITE_M1_SIM_S2;
	end
    `WRITE_M1_SIM_S3 :begin
        if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S3;
	  else NS_W = `WRITE_M1_SIM_S3;
	end
    `WRITE_M1_SIM_S4 :begin
        if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S4;
	  else NS_W = `WRITE_M1_SIM_S4;
	end
	`WRITE_M1_SIM_S5 :begin
        if(WREADY_M1 && WVALID_M1 && WLAST_M1) NS_W = `WRITE_B_M1S5;
	  else NS_W = `WRITE_M1_SIM_S5;
	end
    `default_slave : NS_W = `IDLE;	
	default : begin
	  NS_W = `IDLE;
	end
  endcase
end
/*
logic [3:0] ARLEN_M0_current;
logic [3:0] ARLEN_M0_tmp;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) ARLEN_M0_current <= 4'd0;
    else begin
         ARLEN_M0_tmp <= ARLEN_M0_current;
    end
end
always_comb begin
	if (ARLEN_M0==4'b0001)  ARLEN_M0_current = ARLEN_M0 - 4'b0001;
        else ARLEN_M0_current = ARLEN_M0_tmp;
end

logic [3:0] ARLEN_M1_current;
logic [3:0] ARLEN_M1_tmp;
always@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) ARLEN_M1_current <= 4'd0;
    else begin
         ARLEN_M1_tmp <= ARLEN_M1_current;
    end
end
always_comb begin
	if (ARLEN_M1==4'b0001)  ARLEN_M1_current = ARLEN_M1 - 4'b0001;
        else ARLEN_M1_current = ARLEN_M1_tmp;
end
*/

//jjhu
//READ
/*
always_comb
begin
  case(CS_R)
    `IDLE :begin
	   if(ARVALID_M1) NS_R = `READ_ADDR_M1;     
       else if (ARVALID_M0) NS_R = `READ_ADDR_M0; 	   
	   else NS_R = `IDLE;                     
	end
	
	`READ_ADDR_M0 :begin
	  if(ARVALID_M0 && ARREADY_M0) begin
	     if(ARADDR_M0[16]==1'b0)
	       NS_R = `READ_DATA_M0S0; 
	     else if(ARADDR_M0[16]==1'b1)
	       NS_R = `READ_DATA_M0S1; 
		 else NS_R = `default_slave;
	  end
	  else NS_R = `READ_ADDR_M0;
	end
    `READ_DATA_M0S0 :begin
	  if(RVALID_M0 && RREADY_M0 && RLAST_M0) NS_R = `IDLE;
	  else NS_R = `READ_DATA_M0S0;
	end			
    `READ_DATA_M0S1 :begin
	  if(RVALID_M0 && RREADY_M0 && RLAST_M0) NS_R = `IDLE;
	  else NS_R = `READ_DATA_M0S1;
	end	
    `READ_ADDR_M1 :begin
	  if(ARVALID_M1 && ARREADY_M1) begin
	     if(ARADDR_M1[31:16]==16'd0)
	       NS_R = `READ_DATA_M1S0; 
	     else if(ARADDR_M1[31:16]==16'd1)
	       NS_R = `READ_DATA_M1S1; 
		 else NS_R = `default_slave;
	  end
	  else NS_R = `READ_ADDR_M1;
	end
    `READ_DATA_M1S0 :begin
	  if(RVALID_M1 && RREADY_M1 && RLAST_M1) NS_R = `IDLE;
	  else NS_R = `READ_DATA_M1S0;
	end			
    `READ_DATA_M1S1 :begin
	  if(RVALID_M1 && RREADY_M1 && RLAST_M1) NS_R = `IDLE;
	  else NS_R = `READ_DATA_M1S1;
	end			
   
    `default_slave : NS_R = `IDLE;	
	default : begin
	  NS_R = `IDLE;
	end
  endcase
end
*/
//jjhu
//READ
always_comb begin
    case(CS_R)
	`IDLE: begin
		if(ARVALID_M1 /*&&(RLAST_M1) &&(RREADY_M1)*/ /*&& (~RREADY_M1) &&(~RREADY_M0)*/) begin
		    NS_R = `READ_ADDR_M1;
		end
		else if(ARVALID_M0 /*&&(RLAST_M1) &&(RREADY_M1)*/ /*&& (~RREADY_M1) &&(~RREADY_M0)*/) begin
		    NS_R = `READ_ADDR_M0;
		end
		/*else if (ARVALID_M1 && (ARLEN_M1 ==4'b0000) ) begin
		    NS_R = `READ_ADDR_M1;
		end
		else if (ARVALID_M0 && (ARLEN_M0 ==4'b0000)) begin
		    NS_R = `READ_ADDR_M0;
		end*/
		else begin
		    NS_R = `IDLE;
		end
	end
/*
	`READ_ADDR_M0_B2: begin
	
	end
	`READ_ADDR_M1_B2: begin
	
	end
	`READ_DATA_M0S0_B2: begin
	
	end
	`READ_DATA_M0S1_B2: begin
	
	end
	`READ_DATA_M1S0_B2: begin
	
	end
	`READ_DATA_M1S1_B2: begin
	
	end
*/
	`READ_ADDR_M0: begin
		if(ARVALID_M0 && ARREADY_M0 /*&& (~ARVALID_M1)*/) begin
		    if((ARADDR_M0[31:0]>=32'h0000_0000)&&(ARADDR_M0[31:0]<=32'h0000_3fff)) begin
			    NS_R = `READ_DATA_M0S0;
			end
			else if(ARADDR_M0[31:16]==16'd1) begin
			    NS_R = `READ_DATA_M0S1;
			end
			else if(ARADDR_M0[31:16]==16'd2) begin
			    NS_R = `READ_DATA_M0S2;
			end
			else if((ARADDR_M0[31:0]>=32'h1000_0000)&&(ARADDR_M0[31:0]<=32'h1000_03ff)) begin
			    NS_R = `READ_DATA_M0S3;
			end
			else if((ARADDR_M0[31:0]>=32'h2000_0000)&&(ARADDR_M0[31:0]<=32'h207f_ffff)) begin
			    NS_R = `READ_DATA_M0S4;
			end
			else if(ARADDR_M0[31:16]==16'h3000) begin
			    NS_R = `READ_DATA_M0S5;
			end
			else begin
				//NS_R = `IDLE;			    
				NS_R = `default_slave;
			end
		end
		//jjhu
		/*else if(ARVALID_M0 && RVALID_M0)begin
			if(ARADDR_M0[31:16]==16'd0) begin
				NS_R = `READ_AR_R_M0S0;
			end
			else if(ARADDR_M0[31:16]==16'd1) begin
				NS_R = `READ_AR_R_M0S1; 
			end
			else begin
				NS_R = `default_slave;
			end
          	end*/
		else begin
		    NS_R = `READ_ADDR_M0;
		end
	end
	`READ_DATA_M0S0: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S0;
		end
	end
	`READ_DATA_M0S1: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S1;
		end
	end
	`READ_DATA_M0S2: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S2;
		end
	end
	`READ_DATA_M0S3: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S3;
		end
	end
	`READ_DATA_M0S4: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S4;
		end
	end
	`READ_DATA_M0S5: begin
		if(RVALID_M0 && RREADY_M0 && RLAST_M0) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M0S5;
		end
	end
	
	`READ_ADDR_M1: begin 
	   	if(ARVALID_M1 && ARREADY_M1 /*&&(~ARVALID_M0)*/) begin
			if((ARADDR_M1[31:0]>=32'h0000_0000)&&(ARADDR_M1[31:0]<=32'h0000_3fff)) begin
			    NS_R = `READ_DATA_M1S0;
			end
			else if(ARADDR_M1[31:16]==16'd1) begin
			    NS_R = `READ_DATA_M1S1;
			end
			else if(ARADDR_M1[31:16]==16'd2) begin
			    NS_R = `READ_DATA_M1S2;
			end
			else if((ARADDR_M1[31:0]>=32'h1000_0000)&&(ARADDR_M1[31:0]<=32'h1000_03ff)) begin
			    NS_R = `READ_DATA_M1S3;
			end
			else if((ARADDR_M1[31:0]>=32'h2000_0000)&&(ARADDR_M1[31:0]<=32'h207f_ffff)) begin
			    NS_R = `READ_DATA_M1S4;
			end
			else if(ARADDR_M1[31:16]==16'h3000) begin
			    NS_R = `READ_DATA_M1S5;
			end
			else begin
				//NS_R = `IDLE;			    
				NS_R = `default_slave;
			end
		end
		//jjhu
		/*else if(ARVALID_M1 && RVALID_M1)begin
			if(ARADDR_M1[31:16]==16'd0) begin
				NS_R = `READ_AR_R_M1S0;
			end
			else if(ARADDR_M1[31:16]==16'd1) begin
				NS_R = `READ_AR_R_M1S1; 
			end
			else begin
				NS_R = `default_slave;
			end
          	end*/

		else begin
		    NS_R = `READ_ADDR_M1;
		end	
	end
	`READ_DATA_M1S0: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S0;
		end	
	end
	`READ_DATA_M1S1: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S1;
		end		
	end
	`READ_DATA_M1S2: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S2;
		end	
	end
	`READ_DATA_M1S3: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S3;
		end	
	end
	`READ_DATA_M1S4: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S4;
		end	
	end
	`READ_DATA_M1S5: begin
		if(RVALID_M1 && RREADY_M1 && RLAST_M1) begin
		    NS_R = `IDLE;
		end
		else begin
		    NS_R = `READ_DATA_M1S5;
		end	
	end
	`default_slave: begin
	    NS_R = `IDLE;
	end
	/*`READ_AR_R_M0S0: begin
	    NS_R = (RLAST_M1||RLAST_M0)? `IDLE: `READ_AR_R_M0S0;
	end
	`READ_AR_R_M0S1: begin
	    NS_R = (RLAST_M1||RLAST_M0)? `IDLE: `READ_AR_R_M0S1;
	end
	`READ_AR_R_M1S0: begin
	    NS_R = (RLAST_M1||RLAST_M0)? `IDLE: `READ_AR_R_M1S0;
	end
	`READ_AR_R_M1S1: begin
	    NS_R = (RLAST_M1||RLAST_M0)? `IDLE: `READ_AR_R_M1S1;
	end*/

	default: begin
	    NS_R = `IDLE;
	end
    endcase
end

endmodule


















