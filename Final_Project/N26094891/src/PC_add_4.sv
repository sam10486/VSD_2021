module PC_add_4(input [31:0] PC, 
				output [31:0] PCadd4);

assign PCadd4 = PC + 32'd4;

endmodule