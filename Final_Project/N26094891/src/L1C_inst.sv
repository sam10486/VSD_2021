//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "../include/def.svh"

`define Idle      	 3'b000
`define Read      	 3'b001
`define ReadHit   	 3'b010
`define ReadMiss  	 3'b011
`define ReadRecieve  3'b100



module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] I_out,
  input I_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic I_req,
  output logic [`DATA_BITS-1:0] I_addr,
  output logic I_write,
  output logic [`DATA_BITS-1:0] I_in,
  output logic [`CACHE_TYPE_BITS-1:0] I_type
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


logic [2:0] cs, ns;
logic hit;
logic [2:0] cnt;
assign index = core_addr[9:4];


//--------------------------//
logic [31:0] core_addr_buff;
always@(posedge clk or posedge rst)begin
	if(rst)begin
		core_addr_buff <= 32'd0;
	end
	else if(core_req)begin
		core_addr_buff <= core_addr;
	end
	else begin
		core_addr_buff <= core_addr_buff;
	end
end
logic [5:0] index_test;
assign index_test = (cs == `Idle) ? core_addr_buff[9:4] : core_addr[9:4];

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
			else
				ns = `Idle;
		end
		`Read:begin
			
			if(hit)
				ns = `ReadHit;
			else
				ns = `ReadRecieve;
		end
		`ReadHit:begin
			ns = `Idle;
		end
		`ReadRecieve:begin
			if(~I_wait && (cnt == 3'b011))
				ns = `ReadHit;
			else
				ns = `ReadRecieve;
		end
		default:begin
			ns = `Idle;
		end
	endcase
end


//------------hit------------//
always@(*)begin
	if(valid[index])begin
		if(core_addr[31:10] == TA_out)begin
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
	case(core_addr[3:2])
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




//------------read data from CPU wrapper and store to cache cnt------------//


//------------valid------------//
always@(posedge clk or posedge rst)begin
	if(rst)begin
		valid <= 64'd0;
	end
	else if(cs == `ReadRecieve && ns == `ReadHit)begin
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
		if(~I_wait)begin
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
assign I_type = core_type;
always@(*)begin
	case(cs)
		`Idle:begin//0
			core_out	= `DATA_BITS'd0;			//read data to CPU
			core_wait	= 1'b0;						//wait to CPU
			I_req		= 1'b0;						//request to wrapper
			I_addr		= `DATA_BITS'd0;			//write address to wrapper
			I_write		= 1'b0;						//write signal to wrapper
			I_in		= `DATA_BITS'd0;			//write data to wrapper
			
			DA_read		= 1'b0;						//read signal to data array
			DA_write	= `CACHE_WRITE_BITS'hffff;	//write enable to data array
			DA_in		= `CACHE_DATA_BITS'd0;		//write data to data array
			
			TA_read		= 1'b0;						//read signal to tag array
			TA_write	= 1'b1;						//write enable to tag array
			TA_in		= `CACHE_TAG_BITS'd0;		//write data to tag array
		end
		`Read:begin//1
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			I_req		= 1'b0;
			I_addr		= `DATA_BITS'd0;
			I_write		= 1'b0;
			I_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b0;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b1;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'b0;
		end
		`ReadHit:begin//2
			core_out	= DA_out_32;
			core_wait	= 1'b1;
			I_req		= 1'b0;
			I_addr		= `DATA_BITS'd0;
			I_write		= 1'b0;
			I_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b1;
			DA_write	= `CACHE_WRITE_BITS'hffff;
			DA_in		= `CACHE_DATA_BITS'd0;
			
			TA_read		= 1'b0;
			TA_write	= 1'b1;
			TA_in		= `CACHE_TAG_BITS'd0;
		end
		`ReadRecieve:begin//7
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			//I_req		= (ns == `ReadHit) ? 1'b0 : 1'b1;
			I_req		= (cnt == 3'b011) ? 1'b0 : 1'b1;
			I_addr		= {core_addr[31:4], cnt[1:0], 2'b00};
			I_write		= 1'b0;
			I_in		= `DATA_BITS'd0;
			
			DA_read		= 1'b0;
			case(cnt)
				3'd0:begin
					DA_write	= `CACHE_WRITE_BITS'hfff0;
					DA_in		= {96'd0, I_out};
				end
				3'd1:begin
					DA_write	= `CACHE_WRITE_BITS'hff0f;
					DA_in		= {64'd0, I_out, 32'd0};
				end
				3'd2:begin
					DA_write	= `CACHE_WRITE_BITS'hf0ff;
					DA_in		= {32'd0, I_out, 64'd0};
				end
				3'd3:begin
					DA_write	= `CACHE_WRITE_BITS'h0fff;
					DA_in		= {I_out, 96'd0};
				end
				default:begin
					DA_write	= `CACHE_WRITE_BITS'hffff;
					DA_in		= `CACHE_DATA_BITS'd0;
				end
			endcase
			
			TA_read		= 1'b0;
			TA_write	= 1'b0;
			TA_in		= core_addr[31:10];
		end
		default:begin
			core_out	= `DATA_BITS'd0;
			core_wait	= 1'b1;
			I_req		= 1'b0;
			I_addr		= `DATA_BITS'd0;
			I_write		= 1'b0;
			I_in		= `DATA_BITS'd0;
			
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
