`include "../../include/AXI_define.svh"
`include "Arbiter_R.sv"

module R (
    input ACLK, ARESETn,
	input ARVALID_M0, ARVALID_M1,
    input [`AXI_LEN_BITS-1:0] ARLEN_S0,
    input [`AXI_LEN_BITS-1:0] ARLEN_S4,
    input [`AXI_LEN_BITS-1:0] ARLEN_S3,
	input [`AXI_LEN_BITS-1:0] ARLEN_S2,
	input [`AXI_LEN_BITS-1:0] ARLEN_S1,
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
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
    //READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,
    //READ Data_Default
    input [`AXI_IDS_BITS-1:0] RID_SD,
	input [`AXI_DATA_BITS-1:0] RDATA_SD,
	input [1:0] RRESP_SD,
	input RLAST_SD,
	input RVALID_SD,
	output logic RREADY_SD,

    //------------ROM-------------
    //READ Data_ROM
    input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
    //--------------DRAM------------
    //READ Data_DRAM
    input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,
    //--------------sensor------------
    //READ Data_DRAM
    input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3
);



always_comb begin
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
    case(RID_S2[7:4])
        4'b0001: begin
            RREADY_S2 = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_S2 = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_S2 = 1'd0;
        end
    endcase
    case(RID_SD[7:4])
        4'b0001: begin
            RREADY_SD = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_SD = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_SD = 1'd0;
        end
    endcase
    //--------ROM------------
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
    //-----------DRAM-----------
    case(RID_S4[7:4])
        4'b0001: begin
            RREADY_S4 = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_S4 = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_S4 = 1'd0;
        end
    endcase
    //-----------DRAM-----------
    case(RID_S3[7:4])
        4'b0001: begin
            RREADY_S3 = RVALID_M0 ?  RREADY_M0 : 1'd0;
        end
        4'b0010: begin
            RREADY_S3 = RVALID_M1 ?  RREADY_M1 : 1'd0;
        end
        default: begin
            RREADY_S3 = 1'd0;
        end
    endcase
end

logic slave_S1, slave_S2, slave_Default, slave_S0, slave_S4, slave_S3;
logic [5:0] R_round;
logic R_sel;
logic [5:0] R_Arbiter_grant;
assign slave_S0 = RREADY_S0 & RVALID_S0;
assign slave_S1 = RREADY_S1 & RVALID_S1;
assign slave_S2 = RREADY_S2 & RVALID_S2;
assign slave_S3 = RREADY_S3 & RVALID_S3;
assign slave_S4 = RREADY_S4 & RVALID_S4;
assign slave_Default = RREADY_SD & RVALID_SD;
assign R_sel =  (RVALID_S0 & RVALID_S1) || (RVALID_S0 & RVALID_S2) || (RVALID_S0 & RVALID_S3) || (RVALID_S0 & RVALID_S4) || (RVALID_S0 & RVALID_SD)
                || (RVALID_S1 & RVALID_S2) || (RVALID_S1 & RVALID_S3) || (RVALID_S1 & RVALID_S4) || (RVALID_S1 & RVALID_SD)
                || (RVALID_S2 & RVALID_S3) || (RVALID_S2 & RVALID_S4) || (RVALID_S2 & RVALID_SD)
                || (RVALID_S3 & RVALID_S4) || (RVALID_S3 & RVALID_SD)
                || (RVALID_S4 & RVALID_SD);
Arbiter_R R_Arbiter_R(
    // input
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .round(R_round),
    .slave0_fin(slave_S0),
    .slave1_fin(slave_S1),
    .slave2_fin(slave_S2),
    .slave3_fin(slave_S3),
    .slave4_fin(slave_S4),
    .slave_Default_fin(slave_Default),
    .RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.RLAST_S2(RLAST_S2),
    .RLAST_S3(RLAST_S3),
    .RLAST_S4(RLAST_S4),
	.RLAST_SD(RLAST_SD),
    // output
    .grant(R_Arbiter_grant)

);
assign R_round = (R_sel) ? (R_Arbiter_grant) : {RVALID_SD, RVALID_S4, RVALID_S3, RVALID_S2, RVALID_S1, RVALID_S0};

always_comb begin :slave_decoder
    case(R_round)
         6'b100000: begin //SD
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
        6'b000001: begin //S0
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
        6'b000010: begin //S1
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
        6'b000100: begin //S2
            RID_M0 = RID_S2[3:0];
            RDATA_M0 = RDATA_S2;
            RRESP_M0 = RRESP_S2;
            RLAST_M0 = RLAST_S2;
            RVALID_M0 = (RID_S2[7:4] == 4'b0001) ? RVALID_S2 : 1'd0;

            RID_M1 = RID_S2[3:0];
            RDATA_M1 = RDATA_S2;
            RRESP_M1 = RRESP_S2;
            RLAST_M1 = RLAST_S2;
            RVALID_M1 = (RID_S2[7:4] == 4'b0010) ? RVALID_S2 : 1'd0;
        end
        6'b001000: begin //S3
            RID_M0 = RID_S3[3:0];
            RDATA_M0 = RDATA_S3;
            RRESP_M0 = RRESP_S3;
            RLAST_M0 = RLAST_S3;
            RVALID_M0 = (RID_S3[7:4] == 4'b0001) ? RVALID_S3 : 1'd0;

            RID_M1 = RID_S3[3:0];
            RDATA_M1 = RDATA_S3;
            RRESP_M1 = RRESP_S3;
            RLAST_M1 = RLAST_S3;
            RVALID_M1 = (RID_S3[7:4] == 4'b0010) ? RVALID_S3 : 1'd0;
        end
        6'b010000: begin //S4
            RID_M0 = RID_S4[3:0];
            RDATA_M0 = RDATA_S4;
            RRESP_M0 = RRESP_S4;
            RLAST_M0 = RLAST_S4;
            RVALID_M0 = (RID_S4[7:4] == 4'b0001) ? RVALID_S4 : 1'd0;

            RID_M1 = RID_S4[3:0];
            RDATA_M1 = RDATA_S4;
            RRESP_M1 = RRESP_S4;
            RLAST_M1 = RLAST_S4;
            RVALID_M1 = (RID_S4[7:4] == 4'b0010) ? RVALID_S4 : 1'd0;
        end
        default: begin
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
    endcase
end

endmodule
