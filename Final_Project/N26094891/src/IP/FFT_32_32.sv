//`include "sram_1024_wrapper.sv"

module FFT_32_32(
input							rst,clk,
input							enable,
input 			signed	[31:0]	real_in,
input 			signed	[31:0]	image_in,
output logic 	signed	[31:0]	real_out,
output logic 	signed	[31:0]	image_out,
output logic 			[9:0]	count_out,
output logic 					valid_out
);

logic					enable_sel;
logic signed 	[31:0]	FFT_1_real_out,FFT_1_real_in;
logic signed 	[31:0]	FFT_1_image_out,FFT_1_image_in;

logic 					CS,OE,WEB ;
logic 			[9:0]	A ;
logic signed	[31:0]	real_DI, image_DI, real_DO, image_DO ;

logic			[11:0]	count;
logic			[9:0]	addr;
logic					FFT_1D_finish;
logic 			[4:0]	count2;
logic 			[4:0]	row_count;
logic			[9:0]	addr_2D_FFT;

logic 			[9:0]	count_out_idx;
logic					valid;
logic signed	[31:0]	real_FFT_out;
logic signed	[31:0]	image_FFT_out;


assign CS = OE | ~WEB ;
assign enable_sel = (count == 12'd1060) ? 1'b0 : enable;

sram_1024_wrapper real_sram(
	.CK	(clk),
	.CS	(CS),
	.OE	(OE),
	.WEB(WEB),
	.A	(A),
	.DI	(real_DI),
	.DO	(real_DO)
);

sram_1024_wrapper image_sram(
	.CK	(clk),
	.CS	(CS),
	.OE	(OE),
	.WEB(WEB),
	.A	(A),
	.DI	(image_DI),
	.DO	(image_DO)
);

FFT_32 FFT_1(
.rst     (rst),
.clk     (clk),
.enable  (enable_sel),
.real_in (FFT_1_real_in),
.image_in (FFT_1_image_in),
.real_out(FFT_1_real_out),
.image_out(FFT_1_image_out)
);

reindex reindex1(
.rst     (rst),
.clk     (clk),
.enable  (valid),
.real_in (real_FFT_out),
.image_in (image_FFT_out),
.real_out(real_out),
.image_out(image_out),
.count (count_out_idx),
.valid   (valid_out)
);

//count
always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		count <= 12'd0;
	end
	else begin
		if(enable) begin
			count <= count + 12'd1;
		end
		else begin
			count <= 12'd0;
		end
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		addr <= 10'd0;
	end
	else begin
		if(count > 12'd35 && count < 12'd1059) begin
			addr <= addr + 10'd1;
		end
		else begin
			addr <= 10'd0;
		end
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		FFT_1D_finish <= 1'b0;
	end
	else begin
		if(enable) begin
			if(count == 12'd1059) begin
				FFT_1D_finish <= 1'b1;
			end
		end
		else begin
			FFT_1D_finish <= 1'b0;
		end
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		count2 			<= 5'd0;
		row_count 		<= 5'd0;
	end
	else begin
		if(FFT_1D_finish) begin
			count2		<= count2 + 5'd1;
			if(count2 == 5'd31) begin
				row_count <= row_count + 5'd1;
			end
		end
		else begin
			count2 		<= 5'd0;
			row_count 	<= 5'd0;
		end
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		count_out <= 10'd0 ;
	end
	else begin
		count_out <= count_out_idx;
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		real_FFT_out <= 32'd0;
		image_FFT_out <= 32'd0;
		valid <= 1'd0;
	end
	else begin
		if(count > 12'd1096 && count < 12'd2121) begin
			real_FFT_out <= FFT_1_real_out;
			image_FFT_out <= FFT_1_image_out;
			valid <= 1'd1;
		end
		else if(count > 12'd1096 && count < 12'd3147) begin
			valid <= 1'd1;
		end
		else begin
			real_FFT_out <= 32'd0;
			image_FFT_out <= 32'd0;
			valid <= 1'd0;
		end
	end
end

//signal

assign addr_2D_FFT = {5'd0, row_count} + {count2,5'd0};

always_comb begin
	if(count > 12'd35 && count < 12'd1060) begin
		A 				= addr;
		real_DI 		= FFT_1_real_out;
		image_DI 		= FFT_1_image_out;
		WEB 			= 1'b0;
		OE				= 1'b0;
		FFT_1_real_in 	= real_in;
		FFT_1_image_in 	= image_in;
	end
	else begin
		if(!FFT_1D_finish) begin
			A 				= 10'd0;
			real_DI 		= 32'd0;
			image_DI 		= 32'd0;
			WEB 			= 1'b1;
			OE				= 1'b0;
			FFT_1_real_in 	= real_in;
			FFT_1_image_in 	= image_in;
		end
		else begin
			A 				= addr_2D_FFT;
			real_DI 		= 32'd0;
			image_DI 		= 32'd0;
			WEB 			= 1'b1;
			OE				= 1'b1;
			FFT_1_real_in 	= real_DO;
			FFT_1_image_in 	= image_DO;
		end
	end
end

/*
//test
always_comb begin
	real_out = FFT_1_real_out;
	image_out = FFT_1_image_out;
	valid_out = 1'd1;
end
*/


endmodule