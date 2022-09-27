module MUX2x1(input [31:0] mux_input1, 
				input [31:0] mux_input2, 
				input sel, 
				output logic [31:0] mux_output);

always@(*)begin
	case(sel)
		1'b0: mux_output = mux_input1;
		1'b1: mux_output = mux_input2;
	endcase
end

endmodule