`include "../../include/AXI_define.svh"

module W (
    input ACLK, ARESETn,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input AWVALID_M1,
    //WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
    //WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
    //WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
    //WRITE DATA_S
	output logic [`AXI_DATA_BITS-1:0] WDATA_SD,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_SD,
	output logic WLAST_SD,
	output logic WVALID_SD,
	input WREADY_SD
);

logic [`AXI_ADDR_BITS-1:0] address_now, address_tmp;

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        address_tmp <= 32'd0;
    end else begin
        address_tmp <= address_now;
    end
end

always_comb begin : check_handshake_complete_or_not
    if (AWVALID_M1) begin
        address_now = AWADDR_M1;
    end else begin
        address_now = address_tmp;
    end
end


always_comb begin
    case(address_now[17:16])
        2'b00: begin
            if (WVALID_S0) begin
                WREADY_M1 = WREADY_S0;
            end else begin
                WREADY_M1 = 1'd0;
            end
        end
        2'b01: begin
            if (WVALID_S1) begin
                WREADY_M1 = WREADY_S1;
            end else begin
                WREADY_M1 = 1'd0;
            end
        end
        default: begin
            if (WVALID_SD) begin
                WREADY_M1 = WREADY_SD;
            end else begin
                WREADY_M1 = 1'd0; 
            end
        end
    endcase
end


always_comb begin
    WDATA_S0 = WDATA_M1; 
    WSTRB_S0 = WSTRB_M1;
    WLAST_S0 = WLAST_M1;

    WDATA_S1 = WDATA_M1; 
    WSTRB_S1 = WSTRB_M1;
    WLAST_S1 = WLAST_M1;

    WDATA_SD = WDATA_M1; 
    WSTRB_SD = WSTRB_M1;
    WLAST_SD = WLAST_M1;
    case(address_now[17:16])
        2'b00: begin
            WVALID_S0 = WVALID_M1;
            WVALID_S1 = 1'd0;
            WVALID_SD = 1'd0;
        end
        2'b01: begin
            WVALID_S0 = 1'd0;
            WVALID_S1 = WVALID_M1;
            WVALID_SD = 1'd0;
        end
        default: begin
            WVALID_S0 = 1'd0;
            WVALID_S1 = 1'd0;
            WVALID_SD = WVALID_M1;
        end
    endcase
end

endmodule