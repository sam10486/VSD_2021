`include "define.sv"

module ALU(input [31:0] alu_input1, 
			input [31:0] alu_input2, 
			input [4:0] alu_op, 
			input [2:0] funct3,
			output logic [31:0] alu_output, 
			output logic alu_zero_output);

logic condition;

always@(*)begin
	case(alu_op)
		`ADD: begin
			alu_output = alu_input1 + alu_input2;
			condition = 1'b0;
		end
		`SUB: begin
			alu_output = alu_input1 - alu_input2;
			condition = 1'b0;
		end
		`SLL: begin
			alu_output = alu_input1 << alu_input2[4:0];
			condition = 1'b0;
		end
		`SLT: begin
			alu_output = ($signed(alu_input1) < $signed(alu_input2)) ? 32'd1 : 32'd0;
			condition = alu_output[0];
		end
		`SLTU: begin
			alu_output = ($unsigned(alu_input1) < $unsigned(alu_input2)) ? 32'd1 : 32'd0;
			condition = alu_output[0];
		end
		`XOR: begin
			alu_output = alu_input1 ^ alu_input2;
			condition =| alu_output;
		end
		`SRL:begin
			alu_output = alu_input1 >> alu_input2[4:0];
			condition = 1'b0;
		end
		`SRA: begin
			alu_output = $signed(alu_input1) >>> alu_input2[4:0];
			condition = 1'b0;
		end
		`OR: begin
			alu_output = alu_input1 | alu_input2;
			condition = 1'b0;
		end
		`AND: begin
			alu_output = alu_input1 & alu_input2;
			condition = 1'b0;
		end
		default: begin
			alu_output = 32'd0;
			condition = 1'b0;
		end
	endcase
end

always@(*)begin
	case(funct3)
		3'b000: alu_zero_output = ~condition;		///BEQ
		3'b001: alu_zero_output = condition;		///BNE
		3'b100: alu_zero_output = condition;		///BLT
		3'b101: alu_zero_output = ~condition;		//BGE
		3'b110: alu_zero_output = condition;		///BLTU
		3'b111: alu_zero_output = ~condition;		///BGEU
		default: alu_zero_output = 1'b0;
	endcase
end

endmodule
