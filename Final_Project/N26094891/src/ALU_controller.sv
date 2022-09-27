`include "define.sv"

module ALU_controller(input [6:0] funct7, 
						input [2:0] funct3, 
						input [6:0] opcode, 
						output logic [4:0] alu_control_signal);

always@(*)begin
	case(opcode)
		`R_type_opcode: begin
			case(funct3)
				3'b000: begin
					case(funct7)
						7'b0000000: alu_control_signal = `ADD;
						7'b0100000: alu_control_signal = `SUB;
						default: alu_control_signal = `ALU_function_error;
					endcase
				end
				3'b001: alu_control_signal = `SLL;
				3'b010: alu_control_signal = `SLT;
				3'b011: alu_control_signal = `SLTU;
				3'b100: alu_control_signal = `XOR;
				3'b101: begin
					case(funct7)
						7'b0000000: alu_control_signal = `SRL;
						7'b0100000: alu_control_signal = `SRA;
						default: alu_control_signal = `ALU_function_error;
					endcase
				end
				3'b110: alu_control_signal = `OR;
				3'b111: alu_control_signal = `AND;
			endcase
		end
		`I_type_opcode_1: alu_control_signal = `ADD;
		`I_type_opcode_2: begin
			case(funct3)
				3'b000: alu_control_signal = `ADD;
				3'b001: alu_control_signal = `SLL;
				3'b010: alu_control_signal = `SLT;
				3'b011: alu_control_signal = `SLTU;
				3'b100: alu_control_signal = `XOR;
				3'b101: begin
					case(funct7)
						7'b0000000: alu_control_signal = `SRL;
						7'b0100000: alu_control_signal = `SRA;
						default: alu_control_signal = `ALU_function_error;
					endcase
				end
				3'b110: alu_control_signal = `OR;
				3'b111: alu_control_signal = `AND;
			endcase
		end
		`I_type_opcode_3: alu_control_signal = `ADD;
		`S_type_opcode: alu_control_signal = `ADD;
		`B_type_opcode: begin
			case(funct3)
				3'b000: alu_control_signal = `XOR;
				3'b001: alu_control_signal = `XOR;
				3'b100: alu_control_signal = `SLT;
				3'b101: alu_control_signal = `SLT;
				3'b110: alu_control_signal = `SLTU;
				3'b111: alu_control_signal = `SLTU;
				default: alu_control_signal = `ALU_function_error;
			endcase
		end
		`U_type_opcode_1: alu_control_signal = `ADD;
		`U_type_opcode_2: alu_control_signal = `ADD;
		`J_type_opcode: alu_control_signal = `ADD;
		default: alu_control_signal = `ALU_function_error;
	endcase
end

endmodule
