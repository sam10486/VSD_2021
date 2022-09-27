module FFT_32(
input							rst,clk,
input							enable,
input			signed	[31:0]	real_in,image_in,
output	logic	signed	[31:0]	real_out,image_out
);

logic	signed	[15:0]	tf_real[0:15];
logic	signed	[15:0]	tf_image[0:15];


//twiddle factor
assign tf_real[0]  	=	 16'd16384 ;
assign tf_real[1]  	=	 16'd16069 ;
assign tf_real[2]  	=	 16'd15136 ;
assign tf_real[3]  	=	 16'd13622 ;
assign tf_real[4]  	=	 16'd11585 ;
assign tf_real[5]  	=	 16'd9102  ;
assign tf_real[6]  	=	 16'd6269  ;
assign tf_real[7]  	=	 16'd3196  ;
assign tf_real[8]  	=	 16'd0     ;
assign tf_real[9]  	=	-16'd3197  ;
assign tf_real[10] 	=	-16'd6270  ;
assign tf_real[11] 	=	-16'd9103  ;
assign tf_real[12] 	=	-16'd11586 ;
assign tf_real[13] 	=	-16'd13623 ;
assign tf_real[14] 	=	-16'd15137 ;
assign tf_real[15] 	=	-16'd16070 ;
				   
assign tf_image[0]  =  	-16'd0     ;
assign tf_image[1]  =  	-16'd3197  ;
assign tf_image[2]  =  	-16'd6270  ;
assign tf_image[3]  =  	-16'd9103  ;
assign tf_image[4]  =  	-16'd11586 ;
assign tf_image[5]  =  	-16'd13623 ;
assign tf_image[6]  =  	-16'd15137 ;
assign tf_image[7]  =  	-16'd16070 ;
assign tf_image[8]  =  	-16'd16384 ;
assign tf_image[9]  =  	-16'd16070 ;
assign tf_image[10] =  	-16'd15137 ;
assign tf_image[11] =  	-16'd13623 ;
assign tf_image[12] =  	-16'd11586 ;
assign tf_image[13] =  	-16'd9103  ;
assign tf_image[14] =  	-16'd6270  ;
assign tf_image[15] =  	-16'd3197  ;


logic	[5:0]	count;

logic	[5:0]	count_buf1,count_buf2,count_buf3,count_buf4;


always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		count <= 6'd0;
	end
	else begin
		if(enable) begin
			count <= count + 6'd1;
		end
		else begin
			count <= 6'd0;
		end
	end
end



/////////////////// stage1 ///////////////////
/////////////////// stage1 ///////////////////
/////////////////// stage1 ///////////////////


logic	signed	[31:0]	stage1_reg_real[0:15];
logic	signed	[31:0]	stage1_reg_image[0:15];
logic	signed	[31:0]	BU1_real_out1,BU1_image_out1,BU1_real_out2,BU1_image_out2;
logic	signed	[15:0]	tf_real_stage1,tf_image_stage1;
logic					stage1_mode;
logic	signed	[31:0]	stage1_out_real,stage1_out_image;
logic	signed	[31:0]	stage1_out_real_buf,stage1_out_image_buf;
logic			[3:0]	stage1_index;
integer			i,j;

assign stage1_mode 	= (count[4]) ? 1'd1 : 1'd0;
assign stage1_index = count[3:0];

always_comb begin
	if(count[4] == 1'd0) begin
		tf_real_stage1 	= tf_real[stage1_index];
		tf_image_stage1	= tf_image[stage1_index];
	end
	else begin
		tf_real_stage1 	= 16'd16384;
		tf_image_stage1	= 16'd0;
	end
end

BU BU1(
//input
.op_mode(stage1_mode),
.real_in1(stage1_reg_real[15]),
.real_in2(real_in),
.image_in1(stage1_reg_image[15]),
.image_in2(image_in),
//output
.real_out1(BU1_real_out1),
.real_out2(BU1_real_out2),
.image_out1(BU1_image_out1),
.image_out2(BU1_image_out2)
);

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		for(i=0;i<16;i=i+1) begin
			stage1_reg_real[i] <= 32'd0;
			stage1_reg_image[i] <= 32'd0;
		end
	end
	else begin
		stage1_reg_real[0] <= BU1_real_out1;
		stage1_reg_image[0] <= BU1_image_out1;
		for(j=0;j<15;j=j+1) begin
			stage1_reg_real[j+1] <= stage1_reg_real[j];
			stage1_reg_image[j+1] <= stage1_reg_image[j];
		end
	end
end

complex_mul mul1(
//input
.real_in1(BU1_real_out2),
.image_in1(BU1_image_out2),
.real_in2(tf_real_stage1), 
.image_in2(tf_image_stage1),
//output
.real_out(stage1_out_real), 
.image_out(stage1_out_image)
);


/////////////////// stage2 ///////////////////
/////////////////// stage2 ///////////////////
/////////////////// stage2 ///////////////////


logic	signed	[31:0]	stage2_reg_real[0:7];
logic	signed	[31:0]	stage2_reg_image[0:7];
logic	signed	[31:0]	BU2_real_out1,BU2_image_out1,BU2_real_out2,BU2_image_out2;
logic	signed	[15:0]	tf_real_stage2,tf_image_stage2;
logic					stage2_mode;
logic	signed	[31:0]	stage2_out_real,stage2_out_image;
logic	signed	[31:0]	stage2_out_real_buf,stage2_out_image_buf;
logic			[3:0]	stage2_index;
integer			k,l;

assign stage2_mode 	= (count_buf1[3]) ? 1'd1 : 1'd0;
assign stage2_index = {count_buf1[2:0],1'd0};

always_comb begin
	if(count_buf1[3] == 1'd0) begin
		tf_real_stage2 	= tf_real[stage2_index];
		tf_image_stage2	= tf_image[stage2_index];
	end
	else begin
		tf_real_stage2 	= 16'd16384;
		tf_image_stage2	= 16'd0;
	end
end

BU BU2(
//input
.op_mode(stage2_mode),
.real_in1(stage2_reg_real[7]),
.real_in2(stage1_out_real_buf),
.image_in1(stage2_reg_image[7]),
.image_in2(stage1_out_image_buf),
//output
.real_out1(BU2_real_out1),
.real_out2(BU2_real_out2),
.image_out1(BU2_image_out1),
.image_out2(BU2_image_out2)
);

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		for(k=0;k<8;k=k+1) begin
			stage2_reg_real[k] <= 32'd0;
			stage2_reg_image[k] <= 32'd0;
		end
	end
	else begin
		stage2_reg_real[0] <= BU2_real_out1;
		stage2_reg_image[0] <= BU2_image_out1;
		for(l=0;l<7;l=l+1) begin
			stage2_reg_real[l+1] <= stage2_reg_real[l];
			stage2_reg_image[l+1] <= stage2_reg_image[l];
		end
	end
end

complex_mul mul2(
//input
.real_in1(BU2_real_out2),
.image_in1(BU2_image_out2),
.real_in2(tf_real_stage2), 
.image_in2(tf_image_stage2),
//output
.real_out(stage2_out_real), 
.image_out(stage2_out_image)
);


/////////////////// stage3 ///////////////////
/////////////////// stage3 ///////////////////
/////////////////// stage3 ///////////////////


logic	signed	[31:0]	stage3_reg_real[0:3];
logic	signed	[31:0]	stage3_reg_image[0:3];
logic	signed	[31:0]	BU3_real_out1,BU3_image_out1,BU3_real_out2,BU3_image_out2;
logic	signed	[15:0]	tf_real_stage3,tf_image_stage3;
logic					stage3_mode;
logic	signed	[31:0]	stage3_out_real,stage3_out_image;
logic	signed	[31:0]	stage3_out_real_buf,stage3_out_image_buf;
logic			[3:0]	stage3_index;
integer			m,n;

assign stage3_mode 	= (count_buf2[2]) ? 1'd1 : 1'd0;
assign stage3_index = {count_buf2[1:0],2'd0};

always_comb begin
	if(count_buf2[2] == 1'd0) begin
		tf_real_stage3 	= tf_real[stage3_index];
		tf_image_stage3	= tf_image[stage3_index];
	end
	else begin
		tf_real_stage3 	= 16'd16384;
		tf_image_stage3	= 16'd0;
	end
end

BU BU3(
//input
.op_mode(stage3_mode),
.real_in1(stage3_reg_real[3]),
.real_in2(stage2_out_real_buf),
.image_in1(stage3_reg_image[3]),
.image_in2(stage2_out_image_buf),
//output
.real_out1(BU3_real_out1),
.real_out2(BU3_real_out2),
.image_out1(BU3_image_out1),
.image_out2(BU3_image_out2)
);

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		for(m=0;m<4;m=m+1) begin
			stage3_reg_real[m] <= 32'd0;
			stage3_reg_image[m] <= 32'd0;
		end
	end
	else begin
		stage3_reg_real[0] <= BU3_real_out1;
		stage3_reg_image[0] <= BU3_image_out1;
		for(n=0;n<3;n=n+1) begin
			stage3_reg_real[n+1] <= stage3_reg_real[n];
			stage3_reg_image[n+1] <= stage3_reg_image[n];
		end
	end
end

complex_mul mul3(
//input
.real_in1(BU3_real_out2),
.image_in1(BU3_image_out2),
.real_in2(tf_real_stage3), 
.image_in2(tf_image_stage3),
//output
.real_out(stage3_out_real), 
.image_out(stage3_out_image)
);


/////////////////// stage4 ///////////////////
/////////////////// stage4 ///////////////////
/////////////////// stage4 ///////////////////


logic	signed	[31:0]	stage4_reg_real[0:1];
logic	signed	[31:0]	stage4_reg_image[0:1];
logic	signed	[31:0]	BU4_real_out1,BU4_image_out1,BU4_real_out2,BU4_image_out2;
logic	signed	[15:0]	tf_real_stage4,tf_image_stage4;
logic					stage4_mode;
logic	signed	[31:0]	stage4_out_real,stage4_out_image;
logic	signed	[31:0]	stage4_out_real_buf,stage4_out_image_buf;
logic			[3:0]	stage4_index;
integer			p;

assign stage4_mode 	= (count_buf3[1]) ? 1'd1 : 1'd0;
assign stage4_index = {count_buf3[0],3'd0};

always_comb begin
	if(count_buf3[1] == 1'd0) begin
		tf_real_stage4 	= tf_real[stage4_index];
		tf_image_stage4	= tf_image[stage4_index];
	end
	else begin
		tf_real_stage4 	= 16'd16384;
		tf_image_stage4	= 16'd0;
	end
end

BU BU4(
//input
.op_mode(stage4_mode),
.real_in1(stage4_reg_real[1]),
.real_in2(stage3_out_real_buf),
.image_in1(stage4_reg_image[1]),
.image_in2(stage3_out_image_buf),
//output
.real_out1(BU4_real_out1),
.real_out2(BU4_real_out2),
.image_out1(BU4_image_out1),
.image_out2(BU4_image_out2)
);

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		for(p=0;p<2;p=p+1) begin
			stage4_reg_real[p] <= 32'd0;
			stage4_reg_image[p] <= 32'd0;
		end
	end
	else begin
		stage4_reg_real[0] <= BU4_real_out1;
		stage4_reg_image[0] <= BU4_image_out1;
		
		stage4_reg_real[1] <= stage4_reg_real[0];
		stage4_reg_image[1] <= stage4_reg_image[0];
	end
end

complex_mul mul4(
//input
.real_in1(BU4_real_out2),
.image_in1(BU4_image_out2),
.real_in2(tf_real_stage4), 
.image_in2(tf_image_stage4),
//output
.real_out(stage4_out_real), 
.image_out(stage4_out_image)
);


/////////////////// stage5 ///////////////////
/////////////////// stage5 ///////////////////
/////////////////// stage5 ///////////////////


logic	signed	[31:0]	stage5_reg_real;
logic	signed	[31:0]	stage5_reg_image;
logic	signed	[31:0]	BU5_real_out1,BU5_image_out1,BU5_real_out2,BU5_image_out2;
logic					stage5_mode;
logic	signed	[31:0]	stage5_out_real,stage5_out_image;

assign stage5_mode 	= (count_buf4[0]) ? 1'd1 : 1'd0;

BU BU5(
//input
.op_mode(stage5_mode),
.real_in1(stage5_reg_real),
.real_in2(stage4_out_real_buf),
.image_in1(stage5_reg_image),
.image_in2(stage4_out_image_buf),
//output
.real_out1(BU5_real_out1),
.real_out2(BU5_real_out2),
.image_out1(BU5_image_out1),
.image_out2(BU5_image_out2)
);

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		stage5_reg_real <= 32'd0;
		stage5_reg_image <= 32'd0;
	end
	else begin
		stage5_reg_real <= BU5_real_out1;
		stage5_reg_image <= BU5_image_out1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		real_out <= 32'd0;
		image_out <= 32'd0;
	end
	else begin
		real_out <= BU5_real_out2;
		image_out <= BU5_image_out2;
	end
end

/*
assign real_out 	= BU5_real_out2;
assign image_out	= BU5_image_out2;
*/

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		stage1_out_real_buf		<= 32'd0;
		stage2_out_real_buf		<= 32'd0;
		stage3_out_real_buf		<= 32'd0;
		stage4_out_real_buf		<= 32'd0;
		stage1_out_image_buf	<= 32'd0;
		stage2_out_image_buf	<= 32'd0;
		stage3_out_image_buf	<= 32'd0;
		stage4_out_image_buf	<= 32'd0;
		count_buf1				<= 6'd0;
		count_buf2				<= 6'd0;
		count_buf3				<= 6'd0;
		count_buf4				<= 6'd0;
	end
	else begin
		stage1_out_real_buf		<= stage1_out_real;
		stage2_out_real_buf		<= stage2_out_real;
		stage3_out_real_buf		<= stage3_out_real;
		stage4_out_real_buf		<= stage4_out_real;
		stage1_out_image_buf	<= stage1_out_image;
		stage2_out_image_buf	<= stage2_out_image;
		stage3_out_image_buf	<= stage3_out_image;
		stage4_out_image_buf	<= stage4_out_image;
		count_buf1				<= count;
		count_buf2				<= count_buf1;
		count_buf3				<= count_buf2;
		count_buf4				<= count_buf3;
	end
end

endmodule