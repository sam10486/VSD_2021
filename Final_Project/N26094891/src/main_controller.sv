`include "define.sv"
`include "ALU_controller.sv"

module main_controller(input [31:0] instruction, 
						output logic RegWrite, 
						output logic MemWrite, 
						output logic MemRead, 
						output logic [1:0] ALUSrc1, 
						output logic [1:0] ALUSrc2, 
						output logic ALUSrc3, 
						output logic Branch, 
						output logic [4:0] ALUOp, 
						output logic MemtoReg, 
						output logic Jump);

logic [6:0] opcode;
logic [6:0] funct7;
logic [2:0] funct3;


assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];


ALU_controller ALU_controller1 (.funct7(funct7), .funct3(funct3), .opcode(opcode), .alu_control_signal(ALUOp));


always@(*)begin
	case(opcode)
		`R_type_opcode: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b00;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`I_type_opcode_1: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b1;
			Branch   = 1'b0;
			MemtoReg = 1'b1;
			ALUSrc1  = 2'b01;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`I_type_opcode_2: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b01;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`I_type_opcode_3: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b1;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b10;
			ALUSrc2  = 2'b01;
			ALUSrc3  = 1'b1;
			Jump     = 1'b1;
		end
		`S_type_opcode: begin
			RegWrite = 1'b0;
			MemWrite = 1'b1;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b01;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`B_type_opcode: begin
			RegWrite = 1'b0;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b1;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b00;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`U_type_opcode_1: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b01;
			ALUSrc2  = 2'b01;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`U_type_opcode_2: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b01;
			ALUSrc2  = 2'b10;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		`J_type_opcode: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b1;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b10;
			ALUSrc2  = 2'b01;
			ALUSrc3  = 1'b0;
			Jump     = 1'b1;
		end
		7'b1110011: begin
			RegWrite = 1'b1;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b00;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
		default: begin
			RegWrite = 1'b0;
			MemWrite = 1'b0;
			MemRead  = 1'b0;
			Branch   = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc1  = 2'b00;
			ALUSrc2  = 2'b00;
			ALUSrc3  = 1'b0;
			Jump     = 1'b0;
		end
	endcase
end

endmodule