module reindex(
input rst,
input clk,
input enable,
input signed[31:0]real_in,
input signed[31:0]image_in,
output logic signed[31:0]real_out,
output logic signed[31:0]image_out,
output logic [9:0] count,
output logic  valid
);

logic 				[4:0] 	col_count,row_count;
logic 				[4:0] 	col_reverse,row_reverse;
logic 				[9:0] 	index ;

logic 						CS,OE,WEB;
logic 				[9:0]	A;
logic 				[31:0]	real_DI,image_DI,real_DO,image_DO;

logic						reindex_finish,reindex_finish_buf;
logic						valid_,valid_buf;


assign CS = OE | ~WEB;

sram_1024_wrapper real_sram_reinx(
	.CK	(clk),
	.CS	(CS),
	.OE	(OE),
	.WEB(WEB),
	.A	(A),
	.DI	(real_DI),
	.DO	(real_DO)
);

sram_1024_wrapper imag_sram_reinx(
	.CK	(clk),
	.CS	(CS),
	.OE	(OE),
	.WEB(WEB),
	.A	(A),
	.DI	(image_DI),
	.DO	(image_DO)
);

always_comb
begin
	col_reverse = {col_count[0],col_count[1],col_count[2],col_count[3],col_count[4]};
	row_reverse = {row_count[0],row_count[1],row_count[2],row_count[3],row_count[4]};
	index = {col_reverse,5'd0} + {5'd0,row_reverse};
end

always_comb begin
	if(enable) begin
		if(reindex_finish) begin
			A 			= count;
			real_DI 	= 32'd0;
			image_DI 	= 32'd0;
			WEB 		= 1'b1; 
			OE			= 1'b1;//read
			real_out 	= real_DO;
			image_out 	= image_DO;
		end
		else begin
			A 			= index;
			real_DI 	= real_in;
			image_DI 	= image_in;
			WEB 		= 1'b0; 
			OE			= 1'b0;//read
			real_out 	= 32'd0;
			image_out 	= 32'd0;
		end
	end
	else begin
		A 			= 10'd0;
		real_DI 	= 32'd0;
		image_DI 	= 32'd0;
		WEB 		= 1'b1; 
		OE			= 1'b0;//read
		real_out 	= 32'd0;
		image_out 	= 32'd0;	
	end
end


//count
always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		col_count <= 5'd0;
		row_count <= 5'd0;
		reindex_finish <= 1'd0;
	end
	else begin
		if(enable) begin
			col_count <= col_count + 5'd1;
			if(col_count == 5'd31) begin
				if(row_count == 5'd31) begin
					reindex_finish <= 1'd1;
				end
				row_count <= row_count + 5'd1;
			end
		end
		else begin
			col_count <= 5'd0;
			row_count <= 5'd0;
			reindex_finish <= 1'd0;
		end
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		reindex_finish_buf <= 1'd0;
		valid_buf <= 1'd0;
	end
	else begin
		reindex_finish_buf <= reindex_finish;
		valid_buf <= valid_;
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		count  <= 10'd0;
	end
	else begin
		if(reindex_finish_buf) begin
			count <= count + 10'd1;
        end		
		else begin
			count  <= 10'd0;			
		end
	end
end

assign valid_ = reindex_finish_buf & enable;
assign valid  = valid_ & valid_buf;


endmodule