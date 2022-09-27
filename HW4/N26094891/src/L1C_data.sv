//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "../include/def.svh"
/*`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"*/
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
  
  //core_addr_buffer
  logic [31:0] core_addr_buffer;
  

  //--------------- complete this part by yourself -----------------//
  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );
enum {IDLE, READ, READMISS_SRAM, READHIT, WRITE, WRITEMISS, WRITEHIT, BUFFER, READSENSOR, READSENSOR_recieve, READSENSOR_pass} cs, ns;
assign index = (cs == READMISS_SRAM)?core_addr_buffer[9:4] : core_addr[9:4];
assign D_type = core_type;

logic hit;
logic [1:0] readcount;
logic [`DATA_BITS-1:0] core_out_data;
logic [3:0] write_signal;

//sensor control
logic cacheable;
always_comb cacheable = (core_addr[31:16] != 16'h1000);

//---------reset-----------
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    cs <= IDLE;
    valid <= 64'd0;
  end else begin
    cs <= ns;
    if (cs == READMISS_SRAM && ns == READHIT && cacheable) begin
      valid[index] <= 1'd1;
    end
  end
end
//--------------------

always_comb begin
  if ((core_addr[31:10] == TA_out) && valid[index] && cacheable) begin
    hit = 1'd1;
  end else begin
    hit = 1'd0;
  end
end

always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    readcount <= 2'd0;
  end else begin
    if (cs == READMISS_SRAM && !D_wait) begin
      readcount <= readcount + 2'd1;
    end 
  end
end

always_comb begin 
  case(core_addr_buffer[3:2])
    2'b00: core_out_data = DA_out[31:0];
    2'b01: core_out_data = DA_out[63:32];
    2'b10: core_out_data = DA_out[95:64];
    2'b11: core_out_data = DA_out[127:96];
  endcase
end

always_comb begin
  case(D_type)
    //write byte
    3'b000, 3'b100: begin
      case(core_addr[1:0])
        2'b00: begin
          write_signal = 4'b1110;
        end
        2'b01: begin
          write_signal = 4'b1101;
        end
        2'b10: begin
          write_signal = 4'b1011;
        end
        2'b11: begin
          write_signal = 4'b0111;
        end
      endcase
    end
    //write hword
    3'b001, 3'b101: begin
      case(core_addr[1])
        1'b0: begin
          write_signal = 4'b1100;
        end
        1'b1: begin
          write_signal = 4'b0011;
        end
      endcase
    end
    //write word
    3'b010, 3'b110: begin
      write_signal = 4'b0000;
    end
    default: begin
      write_signal = 4'b1111;
    end
  endcase
end
//--------next state logic-----------
always_comb begin
  case(cs)
    IDLE: begin
      if (core_req) begin
        if (core_write) begin
          ns = WRITE;
        end else begin
          ns = READ;
        end
      end else begin
        ns = IDLE;
      end
    end
    READ: begin
      if (hit) begin
        ns = READHIT;
      end
	  else if(!cacheable) begin
		ns = READSENSOR;
	  end
	  else begin
        ns = READMISS_SRAM;
      end
    end
    READMISS_SRAM: begin
      if (readcount == 2'd3 && !D_wait) begin
        ns = READHIT;
      end else begin
        ns = READMISS_SRAM;
      end
    end
    READHIT: begin
      ns = BUFFER;
    end
	BUFFER: begin
	  ns = IDLE;
	end
	READSENSOR: begin
		ns = READSENSOR_recieve;
	end
	READSENSOR_recieve: begin
		if(!D_wait)
			ns = READSENSOR_pass;
		else
			ns = READSENSOR_recieve;
	end
	READSENSOR_pass: begin
		ns = IDLE;
	end
    WRITE: begin
      if (hit) begin
        ns = WRITEHIT;
      end else begin
        ns = WRITEMISS;
      end
    end
    WRITEMISS: begin
      if (~D_wait) begin
        ns = IDLE;
      end else begin
        ns = WRITEMISS;
      end
    end
    WRITEHIT: begin
      if (~D_wait) begin
        ns = IDLE;
      end else begin
        ns = WRITEHIT;
      end
    end
    default: begin
      ns = IDLE;
    end
  endcase
end
//-----------------

//------control signal---------
always_comb begin
  case(cs)
    IDLE: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd0;
      D_req = 1'd0;
      D_addr = `DATA_BITS'b0;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0; 
    end
    READ: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = 1'd0;
      D_addr = `DATA_BITS'b0;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0; 
    end
    READHIT: begin
      core_out = core_out_data;
      core_wait = 1'd1;
      D_req = 1'd0;
      D_addr = `DATA_BITS'b0;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0; 
    end
    READMISS_SRAM: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = (readcount == 2'd3)?1'd0 : 1'd1;
      D_addr = {core_addr_buffer[31:4], readcount, 2'd0};
      D_write = 1'd0;
      D_in = `DATA_BITS'b0; 
    end
    WRITE: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = 1'd1;
      D_addr = core_addr;
      D_write = 1'd1;
      D_in = `DATA_BITS'b0; 
    end
    WRITEHIT: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = (ns == IDLE)?1'd0:1'd1;
      D_addr = core_addr;
      D_write = 1'd1;
      D_in = core_in; 
    end
    WRITEMISS: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = (ns == IDLE)?1'd0:1'd1;
      D_addr = core_addr;
      D_write = 1'd1;
      D_in = core_in; 
    end
    BUFFER: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd0;
      D_req = 1'd0;
      D_addr = (core_req && core_write)?core_addr:32'd0;
      D_write = (core_req && core_write)?1'd1:1'd0;
      D_in = (core_req && core_write)?core_in:32'd0;
    end
	READSENSOR: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = 1'd1;
      D_addr = core_addr_buffer;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0;
    end
	READSENSOR_recieve: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      D_req = 1'd0;
      D_addr = core_addr_buffer;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0;
    end
	READSENSOR_pass: begin
      core_out = D_out;
      core_wait = 1'd1;
      D_req = 1'd0;
      D_addr = `DATA_BITS'b0;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0;
    end
    default: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd0;
      D_req = 1'd0;
      D_addr = `DATA_BITS'b0;
      D_write = 1'd0;
      D_in = `DATA_BITS'b0; 
    end
  endcase
end


always_comb begin
  case(cs)
    IDLE: begin
      TA_write = 1'd1;
      TA_read = 1'd0;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd0;
      DA_in = `CACHE_DATA_BITS'b0;
    end
    READ: begin
      TA_write = 1'd1;
      TA_read = 1'd1;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd0;
      DA_in = `CACHE_DATA_BITS'b0;
    end
    READHIT: begin
      TA_write = 1'd1;
      TA_read = 1'd0;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd1;
      DA_in = `CACHE_DATA_BITS'b0;
    end
    READMISS_SRAM: begin
      TA_write = 1'd0;
      TA_read = 1'd0;
      TA_in = core_addr_buffer[31:10];
      case(readcount)
        2'b00: begin
          DA_in = {96'd0, D_out};
          DA_write = `CACHE_WRITE_BITS'hfff0;
        end
        2'b01: begin
          DA_in = {64'd0, D_out, 32'd0};
          DA_write = `CACHE_WRITE_BITS'hff0f;
        end
        2'b10: begin
          DA_in = {32'd0, D_out, 64'd0};
          DA_write = `CACHE_WRITE_BITS'hf0ff;
        end
        2'b11: begin
          DA_in = {D_out, 96'd0};
          DA_write = `CACHE_WRITE_BITS'h0fff;
        end
      endcase
      DA_read = 1'd0;
    end
    WRITE: begin
      TA_write = 1'd1;
      TA_read = 1'd1;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd0;
      DA_in = `CACHE_DATA_BITS'b0;
    end
    WRITEHIT: begin
      TA_write = 1'd0;
      TA_read = 1'd0;
      TA_in = core_addr[31:10];
      case(core_addr[3:2])
        2'b00: begin
          DA_write = {12'hfff, write_signal}; //****
          DA_in = {96'd0, core_in};
        end
        2'b01: begin
          DA_write = {8'hff, write_signal, 4'hf}; //*****
          DA_in = {64'd0, core_in, 32'd0};
        end
        2'b10: begin
          DA_write = {4'hf, write_signal, 8'hff}; //*****
          DA_in = {32'd0, core_in, 64'd0};
        end
        2'b11: begin
          DA_write = {write_signal, 12'hfff}; //*****
          DA_in = {core_in, 96'd0};
        end
      endcase
      DA_read = 1'd0;
    end
    WRITEMISS: begin
      TA_write = 1'd1;
      TA_read = 1'd0;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd0;
      DA_in = `CACHE_DATA_BITS'b0;
    end
	READSENSOR: begin
	  TA_write = 1'd1;
      TA_read = 1'd1;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd1;
      DA_in = `CACHE_DATA_BITS'b0;
	end
	READSENSOR_recieve: begin
	  TA_write = 1'd1;
      TA_read = 1'd1;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd1;
      DA_in = `CACHE_DATA_BITS'b0;
	end
	READSENSOR_pass: begin
	  TA_write = 1'd1;
      TA_read = 1'd1;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd1;
      DA_in = `CACHE_DATA_BITS'b0;
	end
    default: begin
      TA_write = 1'd1;
      TA_read = 1'd0;
      TA_in = `CACHE_TAG_BITS'b0;
      DA_write = `CACHE_WRITE_BITS'hffff;
      DA_read = 1'd0;
      DA_in = `CACHE_DATA_BITS'b0;
    end
  endcase
end

//core_addr_buffer
always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		core_addr_buffer <= 32'd0;
	end
	else if(cs == READ) begin
		core_addr_buffer <= core_addr;
	end
end


//------data cache hit--------------
logic b1_data, b2_data;
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    b1_data <= 1'd0;
  end else if (cs == READMISS_SRAM || cs == WRITEMISS) begin
    b1_data <= 1'd1;
  end else begin
    b1_data <= 1'd0;
  end
end
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    b2_data <= 1'd0;
  end else if ((cs == READMISS_SRAM || cs == WRITEMISS) && (b1_data == 1'b0)) begin
    b2_data <= 1'd1;
  end else begin
    b2_data <= 1'd0;
  end
end


logic [31:0] data_miss_number;
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    data_miss_number <= 32'd0;
  end else begin
    if (b2_data == 1'b1) begin
      data_miss_number <= data_miss_number + 32'd1;
    end else begin
      data_miss_number <= data_miss_number;
    end
  end
end


endmodule

