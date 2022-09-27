module ALU_small(input [31:0] alu_input1, 
					input [31:0] alu_input2, 
					output logic [31:0] alu_output);

assign alu_output = alu_input1 + alu_input2;

endmodule