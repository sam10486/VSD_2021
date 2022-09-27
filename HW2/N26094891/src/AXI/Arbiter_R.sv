module Arbiter_R(
    input ACLK, ARESETn,
    input [2:0] round,
    input slave0_fin, slave1_fin, slave_Default_fin,
	input RLAST_S0, RLAST_S1, RLAST_SD,
    output logic [2:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 3'b001;
    end else begin
        if ((slave0_fin & RLAST_S0) || (slave1_fin & RLAST_S1) || (slave_Default_fin & RLAST_SD)) begin
            case(round)
                3'b001: grant <= 3'b010;
                3'b010: grant <= 3'b100;
                default: begin
                    grant <= 3'b001;
                end
            endcase
        end else begin
            grant <= round; 
        end
    end
end

endmodule
