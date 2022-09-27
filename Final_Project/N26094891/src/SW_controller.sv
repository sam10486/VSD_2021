module SW_controller(input sw_en, 
						input [2:0] funct3, 
						input [1:0] alu2bit, 
						output logic [3:0] memwrite);


always@(*)begin
	case(sw_en)
		1'b1: begin
			case(funct3)
				3'b010: memwrite = 4'b0000;//SW
				3'b000: begin//SB
					case(alu2bit)
						2'b00: memwrite = 4'b1110;
						2'b01: memwrite = 4'b1101;
						2'b10: memwrite = 4'b1011;
						2'b11: memwrite = 4'b0111;
					endcase
				end
				3'b001: begin//SH
					case(alu2bit)
						2'b00: memwrite = 4'b1100;
						2'b01: memwrite = 4'b1001;
						2'b10: memwrite = 4'b0011;
						2'b11: memwrite = 4'b1111;
					endcase
				end
				default: memwrite = 4'b1111;
			endcase
		end
		default: memwrite = 4'b1111;
	endcase
end

endmodule