`ifndef DEFINE_V
`define DEFINE_V

///ALU function///
`define ADD  				 5'b00000
`define SUB  				 5'b00001
`define SLL  				 5'b00010
`define SLT  				 5'b00011
`define SLTU 				 5'b00100
`define XOR  				 5'b00101
`define SRL  				 5'b00110
`define SRA  				 5'b00111
`define OR   				 5'b01000
`define AND  				 5'b01001

`define BEQ  				 5'b01010
`define BNE  				 5'b01011
`define BLT  				 5'b01100
`define BGE  				 5'b01101
`define BLTU  				 5'b01110
`define BGEU  				 5'b01111

`define ALU_function_error   5'b11111


///type///
`define R_type_opcode    	7'b0110011
`define I_type_opcode_1  	7'b0000011///Load
`define I_type_opcode_2  	7'b0010011///ADD...
`define I_type_opcode_3  	7'b1100111///Jump
`define S_type_opcode    	7'b0100011
`define B_type_opcode    	7'b1100011
`define U_type_opcode_1    	7'b0010111
`define U_type_opcode_2   	7'b0110111
`define J_type_opcode    	7'b1101111


//////
`endif