module reg32x32(input clk, 
				input rst, 
				input reg_write,
				input [4:0] read_addr1, 
				input [4:0] read_addr2, 
				input [4:0] write_addr, 
				input [31:0] write_data, 
				output logic [31:0] read_data1, 
				output logic [31:0] read_data2);

integer i;


logic [31:0] registers [0:31];

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 32; i = i + 1)begin
			registers[i] <= 32'd0;
		end
	end
	else begin
		if(reg_write)begin
			if(write_addr != 5'd0)begin
				registers[write_addr] <= write_data;
			end
		end
	end
end




always@(*)begin
	if((read_addr1 == write_addr) && reg_write)begin
		if(read_addr1 == 5'd0)begin
			read_data1 = 32'd0;
		end
		else begin
			read_data1 = write_data;
		end
	end
	else begin
		read_data1 = registers[read_addr1];
	end
end

always@(*)begin
	if((read_addr2 == write_addr) && reg_write)begin
		if(read_addr2 == 5'd0)begin
			read_data2 = 32'd0;
		end
		else begin
			read_data2 = write_data;
		end
	end
	else begin
		read_data2 = registers[read_addr2];
	end
end

//assign read_data1 = registers[read_addr1];
//assign read_data2 = registers[read_addr2];

endmodule