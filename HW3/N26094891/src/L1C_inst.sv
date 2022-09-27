//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "../include/def.svh"
/*`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"*/
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

assign index = core_addr[9:4];
enum {IDLE, READ, READMISS_SRAM, READHIT} cs, ns;
logic hit;
logic [1:0] readcount;
logic [`DATA_BITS-1:0] core_out_data;
//---------reset-----------
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    cs <= IDLE;
    valid <= 64'd0;
  end else begin
    cs <= ns;
    if (cs == READMISS_SRAM && ns == READHIT) begin
      valid[index] <= 1'd1;
    end
  end
end
//--------------------

always_comb begin
  if ((core_addr[31:10] == TA_out) && valid[index]) begin
    hit = 1'd1;
  end else begin
    hit = 1'd0;
  end
end

always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    readcount <= 2'd0;
  end else begin
    if (cs == READMISS_SRAM && !I_wait) begin
      readcount <= readcount + 2'd1;
    end 
  end
end

always_comb begin 
  case(core_addr[3:2])
    2'b00: core_out_data = DA_out[31:0];
    2'b01: core_out_data = DA_out[63:32];
    2'b10: core_out_data = DA_out[95:64];
    2'b11: core_out_data = DA_out[127:96];
  endcase
end

//--------next state logic-----------
always_comb begin
  case(cs)
    IDLE: begin
      if (core_req) begin
        ns = READ;
      end else begin
        ns = IDLE;
      end
    end
    READ: begin
      if (hit) begin
        ns = READHIT;
      end else begin
        ns = READMISS_SRAM;
      end
    end
    READMISS_SRAM: begin
      if (readcount == 2'd3 && !I_wait) begin
        ns = READHIT;
      end else begin
        ns = READMISS_SRAM;
      end
    end
    READHIT: begin
      ns = IDLE;
    end
    default: begin
      ns = IDLE;
    end
  endcase
end
//-----------------

//------control signal---------
assign I_type = core_type;
always_comb begin
  case(cs)
    IDLE: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd0;
      I_req = 1'd0;
      I_addr = `DATA_BITS'b0;
      I_write = 1'd0;
      I_in = `DATA_BITS'b0; 
    end
    READ: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      I_req = 1'd0;
      I_addr = `DATA_BITS'b0;
      I_write = 1'd0;
      I_in = `DATA_BITS'b0; 
    end
    READHIT: begin
      core_out = core_out_data;
      core_wait = 1'd1;
      I_req = 1'd0;
      I_addr = `DATA_BITS'b0;
      I_write = 1'd0;
      I_in = `DATA_BITS'b0; 
    end
    READMISS_SRAM: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd1;
      I_req = (readcount == 2'd3)?1'd0 : 1'd1;
      I_addr = {core_addr[31:4], readcount, 2'd0};
      I_write = 1'd0;
      I_in = `DATA_BITS'b0; 
    end
    default: begin
      core_out = `DATA_BITS'b0;
      core_wait = 1'd0;
      I_req = 1'd0;
      I_addr = `DATA_BITS'b0;
      I_write = 1'd0;
      I_in = `DATA_BITS'b0; 
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
      TA_in = core_addr[31:10];
      case(readcount)
        2'b00: begin
          DA_in = {96'd0, I_out};
          DA_write = `CACHE_WRITE_BITS'hfff0;
        end
        2'b01: begin
          DA_in = {64'd0, I_out, 32'd0};
          DA_write = `CACHE_WRITE_BITS'hff0f;
        end
        2'b10: begin
          DA_in = {32'd0, I_out, 64'd0};
          DA_write = `CACHE_WRITE_BITS'hf0ff;
        end
        2'b11: begin
          DA_in = {I_out, 96'd0};
          DA_write = `CACHE_WRITE_BITS'h0fff;
        end
      endcase
      DA_read = 1'd0;
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


//------instruction cache hit--------------
logic b1_instr, b2_instr;
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    b1_instr <= 1'd0;
  end else if (cs == READMISS_SRAM) begin
    b1_instr <= 1'd1;
  end else begin
    b1_instr <= 1'd0;
  end
end
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    b2_instr <= 1'd0;
  end else if ((cs == READMISS_SRAM) && (b1_instr == 1'b0)) begin
    b2_instr <= 1'd1;
  end else begin
    b2_instr <= 1'd0;
  end
end
logic [31:0] instr_miss_number;
always_ff @( posedge clk or posedge rst ) begin
  if (rst) begin
    instr_miss_number <= 32'd0;
  end else begin
    if (b2_instr == 1'b1) begin
      instr_miss_number <= instr_miss_number + 32'd1;
    end else begin
      instr_miss_number <= instr_miss_number;
    end
  end
end

endmodule

