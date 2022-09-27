module LW_MUX(input [31:0] LW_input, 
				input [2:0] funct3, 
				input [1:0] alu2bit, 
				output logic [31:0] LW_output);


always@(*)begin
	case(funct3)
		3'b000: begin//LB
			case(alu2bit)
				2'b00: LW_output = {{24{LW_input[7]}}, LW_input[7:0]};
				2'b01: LW_output = {{24{LW_input[15]}}, LW_input[15:8]};
				2'b10: LW_output = {{24{LW_input[23]}}, LW_input[23:16]};
				2'b11: LW_output = {{24{LW_input[31]}}, LW_input[31:24]};
			endcase
		end
		3'b001: begin//LH
			case(alu2bit)
				2'b00: LW_output = {{16{LW_input[15]}}, LW_input[15:0]};
				2'b01: LW_output = {{16{LW_input[23]}}, LW_input[23:8]};
				2'b10: LW_output = {{16{LW_input[31]}}, LW_input[31:16]};
				2'b11: LW_output = 32'd0;
			endcase
		end
		3'b010: begin//LW
			LW_output = LW_input;
		end
		3'b100: begin//LBU
			case(alu2bit)
				2'b00: LW_output = {24'd0, LW_input[7:0]};
				2'b01: LW_output = {24'd0, LW_input[15:8]};
				2'b10: LW_output = {24'd0, LW_input[23:16]};
				2'b11: LW_output = {24'd0, LW_input[31:24]};
			endcase
		end
		3'b101: begin//LHU
			case(alu2bit)
				2'b00: LW_output = {16'd0, LW_input[15:0]};
				2'b01: LW_output = {16'd0, LW_input[23:8]};
				2'b10: LW_output = {16'd0, LW_input[31:16]};
				2'b11: LW_output = 32'd0;
			endcase
		end
		default: begin
			LW_output = 32'd0;
		end
	endcase
end

endmodule