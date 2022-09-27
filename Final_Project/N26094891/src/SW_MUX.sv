module SW_MUX(input [31:0] SW_MUX_in, 
				input [2:0] funct3, 
				input [1:0] alu2bit, 
				output logic [31:0] SW_MUX_out);


always@(*)begin
	case(funct3)
		3'b010: SW_MUX_out = SW_MUX_in;//SW
		3'b001: begin//SH
			case(alu2bit)
				2'b00: SW_MUX_out = {16'd0, SW_MUX_in[15:0]};
				2'b01: SW_MUX_out = {8'd0, SW_MUX_in[15:0], 8'd0};
				2'b10: SW_MUX_out = {SW_MUX_in[15:0], 16'd0};
				2'b11: SW_MUX_out = 32'd0;
			endcase
		end
		3'b000: begin//SB
			case(alu2bit)
				2'b00: SW_MUX_out = {24'd0, SW_MUX_in[7:0]};
				2'b01: SW_MUX_out = {16'd0, SW_MUX_in[7:0], 8'd0};
				2'b10: SW_MUX_out = {8'd0, SW_MUX_in[7:0], 16'd0};
				2'b11: SW_MUX_out = {SW_MUX_in[7:0], 24'd0};
			endcase
		end
		default: SW_MUX_out = 32'd0;
	endcase
end

endmodule