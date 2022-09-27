`include "../../include/AXI_define.svh"

module DefaultSlave (
    input ACLK,
	input  ARESETn,
	input [`AXI_LEN_BITS-1:0] ARLEN_SD,
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	input [`AXI_IDS_BITS-1:0] AWID_SD,
	input AWVALID_SD,
	output logic AWREADY_SD,
	
	//WRITE DATA0
	input WLAST_SD,
	input WVALID_SD,
	output logic WREADY_SD,
	
	//WRITE RESPONSE0
	output logic [`AXI_IDS_BITS-1:0] BID_SD,
	output logic [1:0] BRESP_SD,
	output logic BVALID_SD,
	input BREADY_SD,
	
	//READ ADDRESS0
	input [`AXI_IDS_BITS-1:0] ARID_SD,
	input ARVALID_SD,
	output logic ARREADY_SD,
	
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID_SD,
	output logic [`AXI_DATA_BITS-1:0] RDATA_SD,
	output logic [1:0] RRESP_SD,
	output logic RLAST_SD,
	output logic RVALID_SD,
	input RREADY_SD
///////////////////////////////////
	
);

logic [`AXI_IDS_BITS-1:0] AWID;
logic [`AXI_IDS_BITS-1:0] RID;
logic [1:0] W_cur_state;
logic [1:0] W_next_state;
logic R_cur_state;
logic R_next_state;
//W channel
always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        W_cur_state <= 2'b00;
        AWID <= 8'd0;
    end else begin
        W_cur_state <= W_next_state;
        if (AWVALID_SD && (W_cur_state == 2'b00 || W_cur_state == 2'b10)) begin
            AWID <= AWID_SD;
        end
    end
end  
//next state logic
always_comb begin 
    case(W_cur_state)
        //IDLE
        2'b00: begin
            if (AWVALID_SD && WVALID_SD && WLAST_SD) begin
                W_next_state = 2'b11;
            end else if (AWVALID_SD) begin
                W_next_state = 2'b01;
            end else begin
                W_next_state = 2'b00;
            end
        end
        //WREADY
        2'b01: begin
            if (WVALID_SD && WLAST_SD) begin
                W_next_state = 2'b11;
            end else begin
                W_next_state = 2'b01;
            end
        end
        //BVALID
        2'b11: begin
            if (BREADY_SD) begin
                W_next_state = 2'b00;
            end else begin
                W_next_state = 2'b11;
            end
        end
        default: begin
            W_next_state = 2'b00;
        end
    endcase
end

always_comb begin 
    case(W_cur_state)
        //IDLE
        2'b00: begin
            AWREADY_SD = 1'd1;
            WREADY_SD = 1'd1;
            BID_SD = 8'd0;
            BRESP_SD = 2'd0;
            BVALID_SD = 1'd0;
        end
        //WREADY
        2'b01: begin
            AWREADY_SD = 1'd0;
            WREADY_SD = 1'd1;
            BID_SD = 8'd0;
            BRESP_SD = 2'd0;
            BVALID_SD = 1'd0;
        end
        //BVALID
        2'b11: begin
            AWREADY_SD = 1'd0;
            WREADY_SD = 1'd0;
            BID_SD = AWID;
            BRESP_SD = 2'd2;
            BVALID_SD = 1'd1;
        end
        default: begin
            AWREADY_SD = 1'd0;
            WREADY_SD = 1'd0;
            BID_SD = 8'd0;;
            BRESP_SD = 2'd0;
            BVALID_SD = 1'd0;
        end
    endcase
end


//R channel
logic [3:0] cnt;
always_ff @ ( posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) begin
		cnt <= 4'd0;
	end else begin
		if (ARVALID_SD) begin
			cnt <= ARLEN_SD;
		end else if (RVALID_SD & RREADY_SD) begin
			cnt <= cnt - 4'd1;
		end else begin
			cnt <= cnt;
		end
	end
end
always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        R_cur_state <= 1'd0;
        RID <= 8'd0;
    end else begin
        R_cur_state <= R_next_state;
        if (ARVALID_SD && !R_cur_state) begin
            RID <= ARID_SD;
        end
    end
end

always_comb begin
	case(R_cur_state)
		1'b0: begin
			if(ARVALID_SD) begin
				R_next_state = 1'b1;
			end else begin
				R_next_state = 1'b0;
			end
		end
		1'b1: begin
			if(RREADY_SD && cnt == 4'd0) begin
				R_next_state = 1'b0;
			end else begin
				R_next_state = 1'b1;
			end
		end
	endcase
end


always_comb begin
    case(R_cur_state)
        //IDLE
        1'b0: begin
            ARREADY_SD = 1'd1;
            RID_SD = 8'd0;
            RDATA_SD = 32'd0;
            RRESP_SD = 2'd0;
            RLAST_SD = 1'd0;
            RVALID_SD = 1'd0;
        end
        //AR
        1'b1: begin
            ARREADY_SD = 1'd0;
            RID_SD = RID;
            RDATA_SD = 32'd0;
			if (cnt == 4'd0) begin
				RRESP_SD = 2'd2;
				RLAST_SD = 1'd1;
				RVALID_SD = 1'd1;
			end else begin
				RRESP_SD = 2'd0;
				RLAST_SD = 1'd0;
				RVALID_SD = 1'd0;
			end
            
        end
    endcase
end
endmodule
