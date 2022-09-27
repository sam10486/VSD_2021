module Arbiter_B (
    input ACLK, ARESETn,
    input [4:0] round,
    input BVALID_M1, BREADY_M1, BVALID_S1, BVALID_S2, BVALID_S3, BVALID_S4,
    output logic [4:0] grant
);

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 5'b00001;
    end else begin
        if (BVALID_M1 & BREADY_M1) begin
            if (round == 5'b00001 && BVALID_S1) begin
                grant <= 5'b00010;
            end else if (round == 5'b00010 && BVALID_S2) begin
                grant <= 5'b00100;
            end else if (round == 5'b00100 && BVALID_S3) begin
                grant <= 5'b01000;
            end else if (round == 5'b01000 && BVALID_S4) begin
                grant <= 5'b00001;
            end else begin
                grant <= 5'b10000;
            end
        end else begin
            grant <= round;
        end
    end
end
endmodule