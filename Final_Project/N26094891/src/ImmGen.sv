`include "define.sv"

module ImmGen(input [31:0] instruction, 
				output logic [31:0] imm);


logic [6:0] opcode;

assign opcode = instruction[6:0];


always@(*)begin
	case(opcode)
		`I_type_opcode_1: imm = {{21{instruction[31]}}, instruction[30:20]};
		`I_type_opcode_2: imm = {{21{instruction[31]}}, instruction[30:20]};
		`I_type_opcode_3: imm = {{21{instruction[31]}}, instruction[30:20]};
		`S_type_opcode: imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
		`B_type_opcode: imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
		`U_type_opcode_1: imm = {instruction[31:12], {12{1'b0}}};
		`U_type_opcode_2: imm = {instruction[31:12], {12{1'b0}}};
		`J_type_opcode: imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
		default: imm = 32'd0;
	endcase
end
endmodule
