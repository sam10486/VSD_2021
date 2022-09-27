module Encoder (
    input ACLK, ARESETn,
    input M0_valid, M1_valid,
    output logic [1:0] sel_valid
);

always_comb begin
    case({M1_valid, M0_valid})
        2'b01: begin
            sel_valid = 2'b01;//m0
        end
        2'b10: begin
            sel_valid = 2'b10;//m1
        end
        default: begin
            sel_valid = 2'b01;
        end
    endcase
end
endmodule