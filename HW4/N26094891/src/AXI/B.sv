`include "../../include/AXI_define.svh"
`include "Arbiter_B.sv"

module B (
    input ACLK, ARESETn,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    //WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

    /*//-------ROM--------
    //WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,*/

    //WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
    //WRITE RESPONSE2
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,

    //-------sensor----------
    //WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

    //-------DRAM----------
    //WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

    //WRITE RESPONSE_Defalut
	input [`AXI_IDS_BITS-1:0] BID_SD,
	input [1:0] BRESP_SD,
	input BVALID_SD,
	output logic BREADY_SD
);

logic [4:0] B_round;
logic B_sel;
logic [4:0] B_Arbiter_grant;

assign B_sel =  (BVALID_S1 & BVALID_S2) || (BVALID_S1 & BVALID_S3) || (BVALID_S1 & BVALID_S4) || (BVALID_S1 & BVALID_SD)
                || (BVALID_S2 & BVALID_S3) || (BVALID_S2 & BVALID_S4) || (BVALID_S2 & BVALID_SD)
                || (BVALID_S3 & BVALID_S4) || (BVALID_S3 & BVALID_SD)
                || (BVALID_S4 & BVALID_SD);
Arbiter_B Arbiter_B(
    // input
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .round(B_round),
    .BVALID_M1(BVALID_M1),
    .BREADY_M1(BREADY_M1),
    .BVALID_S1(BVALID_S1),
    .BVALID_S2(BVALID_S2),
    .BVALID_S3(BVALID_S3),
    .BVALID_S4(BVALID_S4),
    //output
    .grant(B_Arbiter_grant)
);

assign B_round = (B_sel) ? B_Arbiter_grant : {BVALID_SD, BVALID_S4, BVALID_S3, BVALID_S2, BVALID_S1};

always_comb begin 
    case(B_round)
        5'b00001: begin
            BID_M1 = BID_S1[3:0];
            BRESP_M1 = BRESP_S1;
            BVALID_M1 = BVALID_S1;
            BREADY_S1 = BREADY_M1;
            BREADY_S2 = 1'd0;
            BREADY_S3 = 1'd0;
            BREADY_S4 = 1'd0;
            BREADY_SD = 1'd0;
        end
        5'b00010: begin
            BID_M1 = BID_S2[3:0];
            BRESP_M1 = BRESP_S2;
            BVALID_M1 = BVALID_S2;
            BREADY_S1 = 1'd0;
            BREADY_S2 = BREADY_M1;
            BREADY_S3 = 1'd0;
            BREADY_S4 = 1'd0;
            BREADY_SD = 1'd0;
        end
        5'b00100: begin
            BID_M1 = BID_S3[3:0];
            BRESP_M1 = BRESP_S3;
            BVALID_M1 = BVALID_S3;
            BREADY_S1 = 1'd0;
            BREADY_S2 = 1'd0;
            BREADY_S3 = BREADY_M1;
            BREADY_S4 = 1'd0;
            BREADY_SD = 1'd0;
        end
        5'b01000: begin
            BID_M1 = BID_S4[3:0];
            BRESP_M1 = BRESP_S4;
            BVALID_M1 = BVALID_S4;
            BREADY_S1 = 1'd0;
            BREADY_S2 = 1'd0;
            BREADY_S3 = 1'd0;
            BREADY_S4 = BREADY_M1;
            BREADY_SD = 1'd0;
        end
        5'b10000: begin
            BID_M1 = BID_SD[3:0];
            BRESP_M1 = BRESP_SD;
            BVALID_M1 = BVALID_SD;
            BREADY_S1 = 1'd0;
            BREADY_S2 = 1'd0;
			BREADY_S3 = 1'd0;
            BREADY_S4 = 1'd0;
            BREADY_SD = BREADY_M1;
        end
        default: begin
            BID_M1 = 4'd0;;
            BRESP_M1 = 2'd0;
            BVALID_M1 = 1'd0;
            BREADY_S1 = 1'd0;
            BREADY_S2 = 1'd0;
            BREADY_S3 = 1'd0;
            BREADY_S4 = 1'd0;
            BREADY_SD = 1'd0;
        end
    endcase
end

endmodule
