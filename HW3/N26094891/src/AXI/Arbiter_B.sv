module Arbiter_B (
    input ACLK, ARESETn,
    input [3:0] round,
    input BVALID_M1, BREADY_M1, BVALID_S1, BVALID_S2, BVALID_S4,
    output logic [3:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 4'b0001;
    end else begin
        if (BVALID_M1 & BREADY_M1) begin
            if (round == 4'b0001 && BVALID_S1) begin
                grant <= 4'b0010;
            end else if (round == 4'b0010 && BVALID_S2) begin
                grant <= 4'b0100;
            end else if (round == 4'b0100 && BVALID_S4) begin
                grant <= 4'b0001;
            end else begin
                grant <= 4'b1000;
            end
        end else begin
            grant <= round;
        end
    end
end
endmodule