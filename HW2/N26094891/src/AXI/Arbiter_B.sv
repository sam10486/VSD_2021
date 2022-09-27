module Arbiter_B (
    input ACLK, ARESETn,
    input [2:0] round,
    input BVALID_M1, BREADY_M1, BVALID_S0, BVALID_S1,
    output logic [2:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 3'b001;
    end else begin
        if (BVALID_M1 & BREADY_M1) begin
            if (round == 3'b001 && BVALID_S0) begin
                grant <= 3'b010;
            end else if (round == 3'b010 && BVALID_S1) begin
                grant <= 3'b001;
            end else begin
                grant <= 3'b100;
            end
        end else begin
            grant <= round;
        end
    end
end
endmodule