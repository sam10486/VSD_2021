module MUX4x1(input [31:0] mux_input1, 
				input [31:0] mux_input2, 
				input [31:0] mux_input3, 
				input [31:0] mux_input4, 
				input [1:0] sel, 
				output logic [31:0] mux_output);

always@(*)begin
	case(sel)
		2'b00: mux_output = mux_input1;
		2'b01: mux_output = mux_input2;
		2'b10: mux_output = mux_input3;
		2'b11: mux_output = mux_input4;
	endcase
end

endmodule