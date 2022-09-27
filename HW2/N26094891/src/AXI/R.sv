`include "../../include/AXI_define.svh"
`include "Arbiter_R.sv"

module R (
    input ACLK, ARESETn,
	input ARVALID_M0, ARVALID_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_S1,
	input [`AXI_LEN_BITS-1:0] ARLEN_S0,
    //READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
    //READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,
    //READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
    //READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
    //READ Data_Default
    input [`AXI_IDS_BITS-1:0] RID_SD,
	input [`AXI_DATA_BITS-1:0] RDATA_SD,
	input [1:0] RRESP_SD,
	input RLAST_SD,
	input RVALID_SD,
	output logic RREADY_SD
);



always_comb begin
    case(RID_S0[7:4])
        4'b0001: begin
            RREADY_S0 = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_S0 = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_S0 = 1'd0;
        end
    endcase
    case(RID_S1[7:4])
        4'b0001: begin
            RREADY_S1 = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_S1 = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_S1 = 1'd0;
        end
    endcase
    case(RID_SD[7:4])
        4'b0001: begin
            RREADY_SD = RREADY_M0;
        end
        4'b0010: begin
            RREADY_SD = RREADY_M1;
        end
        default: begin
            RREADY_SD = 1'd0;
        end
    endcase
end

logic slave_S0, slave_S1, slave_Default;
logic [2:0] R_round;
logic R_sel;
logic [2:0] R_Arbiter_grant;
assign slave_S0 = RREADY_S0 & RVALID_S0;
assign slave_S1 = RREADY_S1 & RVALID_S1;
assign slave_Default = RREADY_SD & RVALID_SD;
assign R_sel = (RVALID_S0 & RVALID_S1) || (RVALID_S0 & RVALID_SD) || (RVALID_S1 & RVALID_SD);
Arbiter_R R_Arbiter_R(
    // input
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .round(R_round),
    .slave0_fin(slave_S0),
    .slave1_fin(slave_S1),
    .slave_Default_fin(slave_Default),
	.RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.RLAST_SD(RLAST_SD),
    // output
    .grant(R_Arbiter_grant)

);
assign R_round = (R_sel) ? (R_Arbiter_grant) : {RVALID_SD, RVALID_S1, RVALID_S0};

always_comb begin :slave_decoder
    case(R_round)
         3'b100: begin //SD
            RID_M0 = RID_SD[3:0];
            RDATA_M0 = RDATA_SD;
            RRESP_M0 = RRESP_SD;
            RLAST_M0 = RLAST_SD;
            RVALID_M0 = (RID_SD[7:4] == 4'b0001) ? RVALID_SD : 1'd0;

            RID_M1 = RID_SD[3:0];
            RDATA_M1 = RDATA_SD;
            RRESP_M1 = RRESP_SD;
            RLAST_M1 = RLAST_SD;
            RVALID_M1 = (RID_SD[7:4] == 4'b0010) ? RVALID_SD : 1'd0;
        end
        3'b001: begin //S0
            RID_M0 = RID_S0[3:0];
            RDATA_M0 = RDATA_S0;
            RRESP_M0 = RRESP_S0;
            RLAST_M0 = RLAST_S0;
            RVALID_M0 = (RID_S0[7:4] == 4'b0001) ? RVALID_S0 : 1'd0;

            RID_M1 = RID_S0[3:0];
            RDATA_M1 = RDATA_S0;
            RRESP_M1 = RRESP_S0;
            RLAST_M1 = RLAST_S0;
            RVALID_M1 = (RID_S0[7:4] == 4'b0010) ? RVALID_S0 : 1'd0;
        end
        3'b010: begin //S1
            RID_M0 = RID_S1[3:0];
            RDATA_M0 = RDATA_S1;
            RRESP_M0 = RRESP_S1;
            RLAST_M0 = RLAST_S1;
            RVALID_M0 = (RID_S1[7:4] == 4'b0001) ? RVALID_S1 : 1'd0;

            RID_M1 = RID_S1[3:0];
            RDATA_M1 = RDATA_S1;
            RRESP_M1 = RRESP_S1;
            RLAST_M1 = RLAST_S1;
            RVALID_M1 = (RID_S1[7:4] == 4'b0010) ? RVALID_S1 : 1'd0;
        end
        default: begin
            RID_M0 = 4'd0;
            RDATA_M0 = 32'd0;
            RRESP_M0 = 2'd0;
            RLAST_M0 = 1'd0;
            RVALID_M0 = 1'd0;

            //RID_M1 = 4'd0;
            RID_M1 = 4'd0;
            RDATA_M1 = 32'd0;
            RRESP_M1 = 2'd0;
            RLAST_M1 = 1'd0;
            RVALID_M1 = 1'd0;
        end
    endcase
end

endmodule
