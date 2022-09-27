

module Arbiter (
    input ACLK, ARESETn,
    input [1:0] round,
    input master0_finish, master1_finish,
    output logic [1:0] grant
);
    

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (!ARESETn) begin
        grant <= 2'b01;
    end else begin
        if (master0_finish || master1_finish) begin
            grant <= ~round;
        end else if (round != 2'b00) begin
            grant <= round;
        end
    end
end
endmodule
