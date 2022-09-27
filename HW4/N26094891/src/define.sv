`ifndef DEFINE_V
`define DEFINE_V


// R-type operation
`define ADD     4'b0000
`define SUB     4'b0001
`define SLL     4'b0010
`define SLT     4'b0011
`define SLTU    4'b0100
`define XOR     4'b0101
`define SRL     4'b0110
`define SRA     4'b0111
`define OR      4'b1000
`define AND     4'b1001
`define EQ      4'b1010

// ALUop
`define ALUop_R     4'd0
`define ALUop_I     4'd1
`define ALUop_I_J   4'd3
`define ALUop_B     4'd5
`define ALUop_U     4'd6
`define ALUop_U_L   4'd7
`define ALUop_J     4'd8

`define ALUop_LW    4'd2
`define ALUop_SW    4'd4
//opcode
`define R_type      7'b011_0011
`define I_type      7'b001_0011
`define I_type_J    7'b110_0111
`define B_type      7'b110_0011
`define U_type      7'b001_0111
`define U_type_L    7'b011_0111
`define J_type      7'b110_1111

`define LW          7'b000_0011
`define SW          7'b010_0011

`define CSR			7'b111_0011

`endif 