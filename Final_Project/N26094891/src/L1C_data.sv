//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "../include/def.svh"

//1

`define Idle      	 4'b0000
`define Read      	 4'b0001
`define ReadHit   	 4'b0010
`define ReadRecieve  4'b0100
					 
`define Write     	 4'b0101
`define WriteHit   	 4'b0110
`define WriteMiss 	 4'b0111
					 
`define Wait         4'b0011

`define Read_fromsensor		4'b1000
`define Read_fromsensor_rec	4'b1001
`define Read_fromsensor_hit	4'b1010

module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output logic D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [`CACHE_TYPE_BITS-1:0] D_type
);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;

//--------------- complete this part by yourself -----------------//
logic [3:0] cs, ns;
logic hit;
logic [2:0] cnt, cnt_;
logic [31:0] core_addr_buff;
//adding cacheable
logic cacheable;

assign index = (cs == `ReadRecieve) ? core_addr_buff[9:4] : core_addr[9:4];
//assign index = (cs == `Idle) ? core_addr[9:4] : core_addr_buff[9:4];



//jjhu
assign cacheable = (core_addr[31:16] != 16'h1000);//1 for true, 0 for false


//------------FSM------------//
always@(posedge clk or posedge rst)begin
	if(rst)begin
		cs <= `Idle;
	end
	else begin
		cs <= ns;
	end
end

always@(*)begin
	case(cs)
		`Idle:begin
			if(core_req && ~core_write)
				ns = `Read;
			else if(core_req && core_write)
				ns = `Write;
			else
				ns = `Idle;
		end
		`Read:begin
			if(hit)
				ns = `ReadHit;
			//jjhu
			else if(!cacheable) 
				ns = `Read_fromsensor;
			else
				ns = `ReadRecieve;
		end
		`ReadHit:begin
			ns = `Wait;
			//ns = `Idle;
		end
		
		`Wait:begin
			ns = `Idle;
		end
		`ReadRecieve:begin
			if(~D_wait && (cnt == 3'b011))
				ns = `ReadHit;
			else
				ns = `ReadRecieve;
		end
		`Write:begin
			if(hit)
				ns = `WriteHit;
			else
				ns = `WriteMiss;
		end
		`WriteHit:begin
			if(D_wait)
				ns = `WriteHit;
			else
				ns = `Idle;
		end
		`WriteMiss:begin
			if(D_wait)
				ns = `WriteMiss;
			else
				ns = `Idle;
		end
		//jjhu
		`Read_fromsensor: begin
			ns = `Read_fromsensor_rec;
		end
		`Read_fromsensor_rec: begin
			if(~D_wait) 
				ns = `Read_fromsensor_hit;
			else 
				ns = `Read_fromsensor_rec;
		end
		`Read_fromsensor_hit: begin
			ns = `Idle;
		end
		default: begin
			ns = `Idle;
		end
	endcase
end

//--------------------------//
always@(posedge clk or posedge rst)begin
	if(rst)begin
		core_addr_buff <= 32'd0;
	end
	else if(cs == `Read)begin
		core_addr_buff <= core_addr;
	end
	else begin
		core_addr_buff <= core_addr_buff;
	end
end

logic [31:0] core_addr_buff1;
always@(posedge clk or posedge rst)begin
	if(rst)begin
		core_addr_buff1 <= 32'd0;
	end
	else if(core_req)begin
		core_addr_buff1 <= core_addr;
	end
	else begin
		core_addr_buff1 <= core_addr_buff1;
	end
end


//------------hit------------//
always@(*)begin
	if(valid[index])begin
		if(core_addr[31:10] == TA_out && cacheable )begin
			hit = 1'b1;
		end
		else begin
			hit = 1'b0;
		end
	end
	else begin
		hit = 1'b0;
	end
end

//------------core out(read data to CPU)------------//
logic [`DATA_BITS-1:0] DA_out_32;

always@(*)begin
	case(core_addr_buff[3:2])
		2'b00:begin
			DA_out_32 = DA_out[31:0];
		end
		2'b01:begin
			DA_out_32 = DA_out[63:32];
		end
		2'b10:begin
			DA_out_32 = DA_out[95:64];
		end
		2'b11:begin
			DA_out_32 = DA_out[127:96];
		end
	endcase
end






//------------core in(write data to CPU wrapper)------------//
logic [3:0] DA_write_enb;
logic [`DATA_BITS-1:0] DA_in_32;

always@(*)begin
	case(core_type)
		3'b000, 3'b100:begin
			case(core_addr[1:0])
				2'b00:begin
					DA_write_enb = 4'b1110;
					//DA_in_32  = {24'd0, core_in[7:0]};
				end
				2'b01:begin
					DA_write_enb = 4'b1101;
					//DA_in_32  = {16'd0, core_in[7:0], 8'd0};
				end
				2'b10:begin
					DA_write_enb = 4'b1011;
					//DA_in_32  = {8'd0, core_in[7:0], 16'd0};
				end
				2'b11:begin
					DA_write_enb = 4'b0111;
					//DA_in_32  = {core_in[7:0], 24'b0};
				end
			endcase
		end
		3'b001, 3'b101:begin
			case(core_addr[1])
				/*
				2'b00:begin
					DA_write_enb = 4'b1100;
					//DA_in_32  = {16'd0, core_in[15:0]};
				end
				2'b01:begin
					DA_write_enb = 4'b1001;
					//DA_in_32  = {8'd0, core_in[15:0], 8'd0};
				end
				2'b10:begin
					DA_write_enb = 4'b0011;
					//DA_in_32  = {core_in[15:0], 16'd0};
				end
				default:begin
					DA_write_enb = 4'b1111;
					//DA_in_32  = `DATA_BITS'd0;
				end
				*/
				1'b0:begin
					DA_write_enb = 4'b1100;
				end
				1'b1:begin
					DA_write_enb = 4'b0011;
				end
			endcase
		end
		3'b010, 3'b110:begin
			DA_write_enb = 4'b0000;
			//DA_in_32  = core_in;
		end
		default:begin
			DA_write_enb = 4'b1111;
			//DA_in_32  = `DATA_BITS'd0;
		end
	endcase
end

//------------read data from CPU wrapper and store to cache cnt------------//


//------------valid------------//
always@(posedge clk or posedge rst)begin
	if(rst)begin
		valid <= 64'd0;
	end
	else if(cs == `ReadRecieve && ns == `ReadHit && cacheable)begin
		valid[index] <= 1'b1;
	end
	else begin
		valid <= valid;
	end
end


always@(posedge clk or posedge rst)begin
	if(rst)begin
		cnt <= 3'd0;
	end
	else if(cs == `ReadRecieve)begin
		if(~D_wait)begin
			cnt <= cnt + 3'd1;
		end
		else begin
			cnt <= cnt;
		end
	end
	else begin
		cnt <= 3'd0;
	end
end





//------------output signal------------//
assign D_type = core_type;
always@(*)begin
	case(cs)
		`Idle:begin
			core_out	= `DATA_BITS'd0;			//read data to CPU
			core_wait	= 1'b0;						//wait to CPU
			D_req		= 1'b0;						//request to wrapper
			D_addr		= `DATA_BITS'd0;			//write address to wrapper
			D_write		= 1'b0;						//write signal to wrapper
			D_in		= `DATA_BITS'd0;			//write data to wrapper
			
			DA_read		= 1'b0;						//read signal to data array
			DA_write	= `CACHE_WRITE_BITS'hffff;	//write enable to data array
			DA_in		= `CACHE_DATA_BITS'd0;		//write data to data array
			
			TA_read		= 1'b0;						//read signal to tag array
			TA_write	= 1'b1;						//write enable to tag array
			TA_in		= `CACHE_TAG_BITS'd0;		//write data to tag array
		end
		`Read:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			D_req		= 1'b0;
			D_addr		= `DATA_BITS'd0;
			D_write		= 1'b0;
			D_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b0;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b1;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
		`ReadHit:begin
			core_out	= DA_out_32;
			core_wait	= 1'b1;
			D_req		= 1'b0;
			D_addr		= `DATA_BITS'd0;
			D_write		= 1'b0;
			D_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b1;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b0;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
		`ReadRecieve:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			//D_req		= (ns == `ReadHit) ? 1'b0 : 1'b1;
			D_req		= (cnt == 3'b011) ? 1'b0 : 1'b1;
			D_addr		= {core_addr_buff[31:4], cnt[1:0], 2'b00};
			D_write		= 1'b0;
			D_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b0;
			case(cnt)
				3'd0:begin
					DA_write	= `CACHE_WRITE_BITS'hfff0;
					DA_in		= {96'd0, D_out};
				end
				3'd1:begin
					DA_write	= `CACHE_WRITE_BITS'hff0f;
					DA_in		= {64'd0, D_out, 32'd0};
				end
				3'd2:begin
					DA_write	= `CACHE_WRITE_BITS'hf0ff;
					DA_in		= {32'd0, D_out, 64'd0};
				end
				3'd3:begin
					DA_write	= `CACHE_WRITE_BITS'h0fff;
					DA_in		= {D_out, 96'd0};
				end
				default:begin
					DA_write	= `CACHE_WRITE_BITS'hffff;
					DA_in		= `CACHE_DATA_BITS'd0;
				end
			endcase
			
			TA_read		= 1'b0;
			TA_write	= 1'b0;
			TA_in		= core_addr_buff[31:10];
		end
		`Write:begin
			core_out	= `DATA_BITS'd0;					//read data to CPU
			core_wait	= 1'b1;                             //wait to CPU
			D_req		= 1'b1;                             ////request to wrapper
			D_addr		= core_addr;         				////write address to wrapper
			D_write		= 1'b1;              				////write signal to wrapper
			D_in		= `DATA_BITS'b0;           			////write data to wrapper
			                                                
			DA_read		= 1'b0;                             //read signal to data array
			DA_write	= `CACHE_WRITE_BITS'hffff;          //write enable to data array
			DA_in		= `CACHE_DATA_BITS'd0;              //write data to data array
			                                                
			TA_read		= 1'b1;                             //read signal to tag array
			TA_write	= 1'b1;                             //write enable to tag array
			TA_in		= `CACHE_TAG_BITS'd0;               //write data to tag array
		end
		`WriteHit:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			D_req		= (ns == `Idle) ? 1'b0 : 1'b1;
			D_addr		= core_addr;
			D_write		= 1'b1;
			D_in		= core_in;
			
			DA_read		= 1'b0;
			case(core_addr[3:2])
				2'b00:begin
					DA_write	= {12'hfff, DA_write_enb};
					DA_in		= {96'd0, core_in};
				end
				2'b01:begin
					DA_write	= {8'hff, DA_write_enb, 4'hf};
					DA_in		= {64'd0, core_in, 32'd0};
				end
				2'b10:begin
					DA_write	= {4'hf, DA_write_enb, 8'hff};
					DA_in		= {32'd0, core_in, 64'd0};
				end
				2'b11:begin
					DA_write	= {DA_write_enb, 12'hfff};
					DA_in		= {core_in, 96'd0};
				end
			endcase
			
			TA_read		= 1'b0;
			TA_write	= 1'b0;
			TA_in		= core_addr[31:10];
		end
		`WriteMiss:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			D_req		= (ns == `Idle) ? 1'b0 : 1'b1;
			D_addr		= core_addr;
			D_write		= 1'b1;
			D_in		= core_in;
			
			DA_read		= 1'b0;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b0;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
		`Wait:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b0;
			D_req		= 1'b0;
			D_addr		= (core_req && core_write)?core_addr:32'd0;
			D_write		= (core_req && core_write)?1'd1:1'b0;
			D_in		= (core_req && core_write)?core_in:32'd0;
			//D_addr	= 32'd0;
			//D_write	= 1'b0;
			//D_in		= 32'd0;
			
			DA_read		= 1'b0;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b0;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
		//jjhu
		`Read_fromsensor: begin
			core_out	=	`DATA_BITS'd0;
			core_wait	=	1'd1;
			D_req		=	1'd1;
			D_addr		=	core_addr_buff;
			D_write		=	1'd0;
			D_in		=	`DATA_BITS'd0;
				
			DA_read		=	1'd1;
			DA_write	=	`CACHE_WRITE_BITS'hffff;//can't write the sensor 
			DA_in		=	`CACHE_DATA_BITS'd0;
				
			TA_read		=	1'd1;
			TA_write	=	1'd1;
			TA_in		=	`CACHE_TAG_BITS'd0;
			
		end
		`Read_fromsensor_rec: begin
			core_out	=	`DATA_BITS'd0;
			core_wait	=	1'd1;
			D_req		=	1'd0;
			D_addr		=	core_addr_buff;//
			D_write		=	1'd0;
			D_in		=	`DATA_BITS'd0;
				
			DA_read		=	1'd1;
			DA_write	=	`CACHE_WRITE_BITS'hffff;
			DA_in		=	`CACHE_DATA_BITS'd0;
				
			TA_read		=	1'd1;
			TA_write	=	1'd1;
			TA_in		=	`CACHE_TAG_BITS'd0;
			
		end
		`Read_fromsensor_hit: begin
			core_out	=	D_out;
			core_wait	=	1'd1;
			D_req		=	1'd0;
			D_addr		=	`DATA_BITS'd0;
			D_write		=	1'd0;
			D_in		=	`DATA_BITS'd0;
				
			DA_read		=	1'd1;
			DA_write	=	`CACHE_WRITE_BITS'hffff;
			DA_in		=	`CACHE_DATA_BITS'd0;
				
			TA_read		=	1'd1;
			TA_write	=	1'd1;
			TA_in		=	`CACHE_TAG_BITS'd0;
			
		end
		default:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			D_req		= 1'b0;
			D_addr		= `DATA_BITS'd0;
			D_write		= 1'b0;
			D_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b0;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b0;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
	endcase
end

//----------------------------------------------------------------//
  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule
