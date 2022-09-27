module BU(
input 			signed			op_mode,
input 			signed	[31:0]	real_in1,real_in2,image_in1,image_in2,
output logic	signed	[31:0]	real_out1,real_out2,image_out1,image_out2
);


always_comb begin
	if(op_mode) begin
		real_out1 	= real_in1 - real_in2;
		image_out1 	= image_in1 - image_in2;
		real_out2 	= real_in1 + real_in2;
		image_out2 	= image_in1 + image_in2;
	end
	else begin
		real_out1 	= real_in2;
		image_out1 	= image_in2;
		real_out2 	= real_in1;
		image_out2 	= image_in1;
	end
end

endmodule