`include "../../include/AXI_define.svh"
`include "Arbiter.sv"
`include "Encoder.sv"
module AR (
    input ACLK, ARESETn,
    input RLAST_S0,
	input RLAST_S1,
	input RLAST_S2,
    input RLAST_S4, 
	input RLAST_SD,
    //READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
    //READ ADDRESS2
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
    //READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
    input RVALID_S1,
	input RREADY_S1,
	input ARREADY_S1,
    //READ ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
    input RVALID_S2,
	input RREADY_S2,
	input ARREADY_S2,
    //READ ADDRESS Default
    input RVALID_SD,
	input RREADY_SD,
    input ARREADY_SD,
    output logic [`AXI_IDS_BITS-1:0] ARID_SD,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_SD,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_SD,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_SD,
    output logic [1:0] ARBURST_SD,
    output logic ARVALID_SD,

    //-------ROM----------
    //READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
    input RVALID_S0,
	input RREADY_S0,
	input ARREADY_S0,
    //-----------------------------

    //--------DRAM------------
    //READ ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
    input RVALID_S4,
	input RREADY_S4,
	input ARREADY_S4

);
logic [1:0] AR_master_sel;
logic [1:0] AR_Arbiter_grant;
logic [1:0] AR_round;
logic state_S0, state_S1, state_S2, state_S4, state_SD;

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        state_S0 <= 1'd0;
        state_S1 <= 1'd0;
        state_S2 <= 1'd0;
        state_S4 <= 1'd0;
        state_SD <= 1'd0;
    end else begin
        if (ARVALID_S1 && ARREADY_S1) begin
            state_S1 <= 1'b1;
        end else if (RVALID_S1 && RREADY_S1 && RLAST_S1) begin
            state_S1 <= 1'b0;
        end
        if (ARVALID_S2 && ARREADY_S2) begin
            state_S2 <= 1'b1;
        end else if (RVALID_S2 && RREADY_S2 && RLAST_S2) begin
            state_S2 <= 1'b0;
        end
        if (ARVALID_SD && ARREADY_SD) begin
            state_SD <= 1'b1;
        end else if (RVALID_SD && RREADY_SD && RLAST_SD) begin
            state_SD <= 1'b0;
        end
        //-----ROM----------
        if (ARVALID_S0 && ARREADY_S0) begin
            state_S0 <= 1'b1;
        end else if (RVALID_S0 && RREADY_S0 && RLAST_S0) begin
            state_S0 <= 1'b0;
        end
        //------------------
        //----DRAM----------
        if (ARVALID_S4 && ARREADY_S4) begin
            state_S4 <= 1'b1;
        end else if (RVALID_S4 && RREADY_S4 && RLAST_S4) begin
            state_S4 <= 1'b0;
        end
        //----------------
    end
end
// for one master act
Encoder encoder(
    // input
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .M0_valid(ARVALID_M0),
    .M1_valid(ARVALID_M1),
    // output
    .sel_valid(AR_master_sel)
);
//for two master act
Arbiter Arbiter(
    // input
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .round(AR_round),
    .master0_finish(ARREADY_M0),
    .master1_finish(ARREADY_M1),
    // output
    .grant(AR_Arbiter_grant)
);
logic ARsel;
assign ARsel = ARVALID_M0 & ARVALID_M1;
//arbiter_result
assign AR_round = ARsel ? AR_Arbiter_grant : AR_master_sel;

always_comb begin: master_decoder
    case({ARVALID_S4, ARVALID_S2, ARVALID_S1, ARVALID_S0, ARVALID_SD})
        5'b00001: begin
            ARREADY_M0 = ARREADY_SD & AR_round[0];
            ARREADY_M1 = ARREADY_SD & AR_round[1];
        end
        5'b00100: begin
            ARREADY_M0 = ARREADY_S1 & AR_round[0];
            ARREADY_M1 = ARREADY_S1 & AR_round[1];
        end
        5'b01000: begin
            ARREADY_M0 = ARREADY_S2 & AR_round[0];
            ARREADY_M1 = ARREADY_S2 & AR_round[1];
        end
        //------ROM-------
        5'b00010: begin
            ARREADY_M0 = ARREADY_S0 & AR_round[0];
            ARREADY_M1 = ARREADY_S0 & AR_round[1];
        end
        //-------DRAM------
        5'b10000: begin
            ARREADY_M0 = ARREADY_S4 & AR_round[0];
            ARREADY_M1 = ARREADY_S4 & AR_round[1];
        end
        default: begin
            ARREADY_M0 = 1'd0;
            ARREADY_M1 = 1'd0;
        end
    endcase
end
always_comb begin
    case(AR_round)
        //M0 source
        2'b01: begin
            ARID_S1 = {4'b0001, ARID_M0};
            ARADDR_S1 = ARADDR_M0;
            ARLEN_S1 = ARLEN_M0;
            ARSIZE_S1 = ARSIZE_M0;
            ARBURST_S1 = ARBURST_M0;
            if (state_S1) begin
                ARVALID_S1 = 1'd0;
            end else begin
                ARVALID_S1 = (ARADDR_M0>=32'h0001_0000 && ARADDR_M0<32'h0002_0000)?ARVALID_M0:1'd0;
            end

            ARID_S2 = {4'b0001, ARID_M0};
            ARADDR_S2 = ARADDR_M0;
            ARLEN_S2 = ARLEN_M0;
            ARSIZE_S2 = ARSIZE_M0;
            ARBURST_S2 = ARBURST_M0;
            if (state_S2) begin
                ARVALID_S2 = 1'd0;
            end else begin
                ARVALID_S2 = (ARADDR_M0>=32'h0002_0000 && ARADDR_M0<32'h0003_0000)?ARVALID_M0:1'd0;
            end

            ARID_SD = {4'b0001, ARID_M0};
            ARADDR_SD = ARADDR_M0;
            ARLEN_SD = ARLEN_M0;
            ARSIZE_SD = ARSIZE_M0;
            ARBURST_SD = ARBURST_M0;
            if (state_SD) begin
                ARVALID_SD = 1'd0;
            end else begin
                ARVALID_SD = ((ARADDR_M0 >= 32'h0003_0000 && ARADDR_M0 < 32'h1fff_ffff) || (ARADDR_M0 >= 32'h2020_0000 && ARADDR_M0 < 32'hffff_ffff)) ? ARVALID_M0 : 1'd0;
            end

            //---------ROM---------------
            ARID_S0 = {4'b0001, ARID_M0};
            ARADDR_S0 = ARADDR_M0;
            ARLEN_S0 = ARLEN_M0;
            ARSIZE_S0 = ARSIZE_M0;
            ARBURST_S0 = ARBURST_M0;
            if (state_S0) begin
                ARVALID_S0 = 1'd0;
            end else begin
                ARVALID_S0 = (ARADDR_M0>=32'h0000_0000 && ARADDR_M0<32'h0000_2000)?ARVALID_M0:1'd0;
            end
            //----------DRAM---------------------
            ARID_S4 = {4'b0001, ARID_M0};
            ARADDR_S4 = ARADDR_M0;
            ARLEN_S4 = ARLEN_M0;
            ARSIZE_S4 = ARSIZE_M0;
            ARBURST_S4 = ARBURST_M0;
            if (state_S4) begin
                ARVALID_S4 = 1'd0;
            end else begin
                ARVALID_S4 = (ARADDR_M0>=32'h2000_0000 && ARADDR_M0<=32'h201f_ffff)?ARVALID_M0:1'd0;
            end
            //-------------------
        end
        //M1 source
        2'b10: begin
            ARID_S1 = {4'b0010, ARID_M1};
            ARADDR_S1 = ARADDR_M1;
            ARLEN_S1 = ARLEN_M1;
            ARSIZE_S1 = ARSIZE_M1;
            ARBURST_S1 = ARBURST_M1;
            if (state_S1) begin
                ARVALID_S1 = 1'd0;
            end else begin
                ARVALID_S1 = (ARADDR_M1>=32'h0001_0000 && ARADDR_M1<32'h0002_0000)?ARVALID_M1:1'd0;
            end

            ARID_S2 = {4'b0010, ARID_M1};
            ARADDR_S2 = ARADDR_M1;
            ARLEN_S2 = ARLEN_M1;
            ARSIZE_S2 = ARSIZE_M1;
            ARBURST_S2 = ARBURST_M1;
            if (state_S2) begin
                ARVALID_S2 = 1'd0;
            end else begin
                ARVALID_S2 = (ARADDR_M1>=32'h0002_0000 && ARADDR_M1<32'h0003_0000)?ARVALID_M1:1'd0;
            end

            ARID_SD = {4'b0010, ARID_M1};
            ARADDR_SD = ARADDR_M1;
            ARLEN_SD = ARLEN_M1;
            ARSIZE_SD = ARSIZE_M1;
            ARBURST_SD = ARBURST_M1;
            if (state_SD) begin
                ARVALID_SD = 1'd0;
            end else begin
                ARVALID_SD = ((ARADDR_M1 >= 32'h0003_0000 && ARADDR_M1 < 32'h1fff_ffff) || (ARADDR_M1 >= 32'h2020_0000 && ARADDR_M1 < 32'hffff_ffff)) ? ARVALID_M1 : 1'd0;
            end

            //---------ROM---------------
            ARID_S0 = {4'b0010, ARID_M1};
            ARADDR_S0 = ARADDR_M1;
            ARLEN_S0 = ARLEN_M1;
            ARSIZE_S0 = ARSIZE_M1;
            ARBURST_S0 = ARBURST_M1;
            if (state_S0) begin
                ARVALID_S0 = 1'd0;
            end else begin
                ARVALID_S0 = (ARADDR_M1>=32'h0000_0000 && ARADDR_M1<32'h0000_2000)?ARVALID_M1:1'd0;
            end
            //----------DRAM---------------------
            ARID_S4 = {4'b0010, ARID_M1};
            ARADDR_S4 = ARADDR_M1;
            ARLEN_S4 = ARLEN_M1;
            ARSIZE_S4 = ARSIZE_M1;
            ARBURST_S4 = ARBURST_M1;
            if (state_S4) begin
                ARVALID_S4 = 1'd0;
            end else begin
                ARVALID_S4 = (ARADDR_M1>=32'h2000_0000 && ARADDR_M1<=32'h201f_ffff)?ARVALID_M1:1'd0;
            end
            //-------------------
        end
        default: begin
            ARID_S1 = 8'd0;
            ARADDR_S1 = 32'd0;
            ARLEN_S1 = 4'd0;
            ARSIZE_S1 = 3'd0;
            ARBURST_S1 = 2'd0;
            ARVALID_S1 = 1'd0;

            ARID_S2 = 8'd0;
            ARADDR_S2 = 32'd0;
            ARLEN_S2 = 4'd0;
            ARSIZE_S2 = 3'd0;
            ARBURST_S2 = 2'd0;
            ARVALID_S2 = 1'd0;

            ARID_SD = 8'd0;
            ARADDR_SD = 32'd0;
            ARLEN_SD = 4'd0;
            ARSIZE_SD = 3'd0;
            ARBURST_SD = 2'd0;
            ARVALID_SD = 1'd0;

            //----------ROM--------------------
            ARID_S0 = 8'd0;
            ARADDR_S0 = 32'd0;
            ARLEN_S0 = 4'd0;
            ARSIZE_S0 = 3'd0;
            ARBURST_S0 = 2'd0;
            ARVALID_S0 = 1'd0;
            //------------DRAM------------
            ARID_S4 = 8'd0;
            ARADDR_S4 = 32'd0;
            ARLEN_S4 = 4'd0;
            ARSIZE_S4 = 3'd0;
            ARBURST_S4 = 2'd0;
            ARVALID_S4 = 1'd0;
        end
    endcase
    
end

endmodule
