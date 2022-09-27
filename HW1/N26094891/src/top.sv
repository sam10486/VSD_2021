`include "CPU.sv"
`include "SRAM_wrapper.sv"

module top (
    input clk,rst
);


logic IM_CS, IM_OE, DM_CS, DM_OE;
logic [3:0] IM_WEB, DM_WEB;
logic [31:0] IM_addr, DM_addr;
logic [31:0] DM_data_in;
logic [31:0] IM_data_out, DM_data_out;

CPU CPU(
    //input
    .clk(clk),
    .rst(rst),
    //output
    .IM_data_out(IM_data_out),
    .DM_data_out(DM_data_out),
    .IM_addr(IM_addr),
    .DM_addr(DM_addr),
    .DM_data_in(DM_data_in),
    .IM_CS(IM_CS),
    .IM_OE(IM_OE),
    .DM_CS(DM_CS),
    .DM_OE(DM_OE),
    .IM_WEB(IM_WEB),
    .DM_WEB(DM_WEB)
);

SRAM_wrapper IM1(
    .CK(clk),
    .CS(IM_CS),
    .OE(IM_OE),
    .WEB(IM_WEB),
    .A(IM_addr[15:2]),
    .DI(32'd0),
    .DO(IM_data_out)
);


SRAM_wrapper DM1(
    .CK(clk),
    .CS(DM_CS),
    .OE(DM_OE),
    .WEB(DM_WEB),
    .A(DM_addr[15:2]),
    .DI(DM_data_in),
    .DO(DM_data_out)
);

endmodule