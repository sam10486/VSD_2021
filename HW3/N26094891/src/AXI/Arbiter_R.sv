module Arbiter_R(
    input ACLK, ARESETn,
    input [4:0] round,
    input slave0_fin, slave1_fin, slave_Default_fin, slave2_fin, slave4_fin,
	input RLAST_S0, RLAST_S1, RLAST_S2, RLAST_S4, RLAST_SD,
    output logic [4:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 5'b00001;
    end else begin
        if ((slave0_fin & RLAST_S0) || (slave1_fin & RLAST_S1) || (slave2_fin & RLAST_S2) || (slave4_fin & RLAST_S4) || (slave_Default_fin & RLAST_SD)) begin
            case(round)
                5'b00001: grant <= 5'b00010;
                5'b00010: grant <= 5'b00100;
                5'b00100: grant <= 5'b01000;
                5'b01000: grant <= 5'b10000;
                default: begin
                    grant <= 5'b00001;
                end
            endcase
        end else begin
            grant <= round; 
        end
    end
end

endmodule
