module Arbiter_R(
    input ACLK, ARESETn,
    input [5:0] round,
    input slave0_fin, slave1_fin, slave_Default_fin, slave2_fin, slave4_fin, slave3_fin,
	input RLAST_S0, RLAST_S1, RLAST_S2, RLAST_S4, RLAST_SD, RLAST_S3,
    output logic [5:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 6'b000001;
    end else begin
        if ((slave0_fin & RLAST_S0) || (slave1_fin & RLAST_S1) || (slave2_fin & RLAST_S2) || (slave3_fin & RLAST_S3) || (slave4_fin & RLAST_S4) || (slave_Default_fin & RLAST_SD)) begin
            case(round)
                6'b000001: grant <= 6'b000010;
                6'b000010: grant <= 6'b000100;
                6'b000100: grant <= 6'b001000;
                6'b001000: grant <= 6'b010000;
                6'b010000: grant <= 6'b100000;
                default: begin
                    grant <= 6'b000001;
                end
            endcase
        end else begin
            grant <= round; 
        end
    end
end

endmodule
