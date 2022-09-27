module complex_mul(
input signed 		[31:0]	real_in1,
input signed 		[31:0]	image_in1,
input signed 		[15:0]	real_in2,   //twinddle factor
input signed 		[15:0]	image_in2,   //twinddle factor
output logic signed [31:0]	real_out, 
output logic signed [31:0]	image_out
);

//( a + bi ) * ( c + di )= ac - bd + i*( bc + ad )

logic signed 		[47:0]	real1_real2_mul_tmp; 
logic signed 		[47:0]	image1_image2_mul_tmp;
logic signed 		[47:0]	real1_image2_mul_tmp; 
logic signed 		[47:0]	image1_real2_mul_tmp; 
logic signed 		[47:0]	real_out_tmp; 
logic signed 		[47:0]	image_out_tmp; 


always_comb begin
	real1_real2_mul_tmp 	= real_in1 * real_in2;
	image1_image2_mul_tmp 	= image_in1 * image_in2;
	image1_real2_mul_tmp 	= image_in1 * real_in2;
	real1_image2_mul_tmp 	= real_in1 * image_in2;
	
	real_out_tmp 			= real1_real2_mul_tmp - image1_image2_mul_tmp;
	image_out_tmp 			= image1_real2_mul_tmp + real1_image2_mul_tmp;
	
	real_out 				= {real_out_tmp[47],real_out_tmp[44:14]};
	image_out 				= {image_out_tmp[47],image_out_tmp[44:14]};
end


endmodule