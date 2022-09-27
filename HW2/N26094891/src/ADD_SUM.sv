`include "define.sv"

module ADD_SUM (
    input logic sel,
    input logic [31:0] PC,
    input logic [31:0] imm,
    output logic [31:0] PC_out
);

assign PC_out = (sel) ? (PC + imm) : (PC + 32'd4);

endmodule