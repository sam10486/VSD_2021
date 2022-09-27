`include "sram_1024_wrapper.sv"
`include "controller.sv"
`include "FFT_32_32.sv"
`include "divider_top.sv"
`include "complex_multiply.sv"
`include "IFFT_32_32.sv"
`include "reindex.sv"
`include "sign_process.sv"
`include "BU.sv"
`include "FFT_32.sv"
`include "complex_mul.sv"
module IP_top (
    input rst,
    input clk,
    input [1:0] instr,
    input [9:0] sram_addr_in,
    input [31:0] sram_data_in,
    input sram0_we,
    input sram1_OE,
    input [9:0] sram1_addr_in,
    output logic [31:0] response_DO
);
    // sram_fram
    logic sram_fram_CS, sram_fram_OE, sram_fram_WEB;
    logic [9:0] sram_fram_A;
    logic [31:0] sram_fram_DI;
    logic [31:0] sram_fram_DO;

    // controller
    logic [1:0] ctr_instr;
    logic [9:0] ctr_fft_addr_out;
    logic [9:0] ctr_div_addr_out;
    logic [9:0] ctr_ifft_addr_out;
    logic ctr_sram0_addr_sel;
    logic [9:0] ctr_sram0_addr;
    logic ctr_sram_oe;
    logic ctr_fft_data_sel;
    logic ctr_fft_en;
    logic ctr_ifft_en;
    logic ctr_sram1_addr_sel;
    
    // fft
    logic fft_enable;
    logic [31:0] fft_real_in;
    logic [31:0] fft_imag_in;
    logic signed [31:0] fft_real_out;
    logic signed[ 31:0] fft_imag_out;
    logic [9:0] fft_count_out;
    logic fft_valid_out;
    // div
    logic [31:0] div_fft_real_in;
    logic [31:0] div_fft_imag_in;
    logic [9:0] div_addr_in;
    logic div_enable_in;
    logic [31:0] div_H_real_out;
    logic [31:0] div_H_imag_out;
    logic [9:0] div_addr_out;
    logic div_enable_out;
    // prodcut mode preprocess
    logic [31:0] fft_real_in_product_mode;
    logic [31:0] fft_imag_in_product_mode;
    logic [9:0] fft_count_product_mode;
    logic fft_valid_product_mode;

    logic [31:0] fft_real_in_product_mode_delay1;
    logic [31:0] fft_imag_in_product_mode_delay1;
    logic [9:0] fft_count_product_mode_delay1;
    logic fft_valid_product_mode_delay1;

    // H_real
    logic H_real_CS;
    logic H_real_OE;
    logic H_real_WEB;
    logic [9:0] H_real_A; 
    logic [31:0] H_real_DI;
    logic [31:0] H_real_DO; 
    // H_imag
    logic H_imag_CS;
    logic H_imag_OE;
    logic H_imag_WEB;
    logic [9:0] H_imag_A; 
    logic [31:0] H_imag_DI;
    logic [31:0] H_imag_DO; 

    // mul
    logic [31:0] mul_a;
    logic [31:0] mul_b;
    logic [31:0] mul_c;
    logic [31:0] mul_d;
    logic [9:0] mul_addr;
    logic mul_enable;
    logic [31:0] mul_real_out;
    logic [31:0] mul_imag_out;
    logic [9:0] mul_addr_out;
    logic mul_enable_out;

    // IFFT
    logic ifft_enable_in;
    logic [31:0] ifft_real_in; 
    logic [31:0] ifft_imag_in;
    logic [31:0] ifft_real_out;
    logic [31:0] ifft_imag_out;
    logic [9:0] ifft_counter_out;
    logic ifft_valid_out;

    // sram_response
    logic sram_response_CS; 
    logic sram_response_OE;
    logic sram_response_WEB;
    logic [9:0] sram_response_A; 
    logic [31:0] sram_response_DI;
    logic [31:0] sram_response_DO; 

    // sram_fram
        // sram data delay one cycle;
    logic ctr_sram_oe_delay;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            ctr_sram_oe_delay <= 1'd0;
        end else begin
            ctr_sram_oe_delay <= ctr_sram_oe;
        end
    end
    assign sram_fram_CS = sram0_we | ctr_sram_oe;
    assign sram_fram_OE = ctr_sram_oe_delay;
    assign sram_fram_WEB = !sram0_we;
    assign sram_fram_A = (ctr_sram0_addr_sel) ? ctr_sram0_addr : sram_addr_in;
    assign sram_fram_DI = sram_data_in;

    // fft
        // because of sram output data delay
    logic fft_enable_delay;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            fft_enable_delay <= 1'd0; 
        end else begin
            fft_enable_delay <= ctr_fft_en;
        end
    end
	assign fft_real_in = sram_fram_DO;
    assign fft_imag_in = 32'd0;
    assign fft_enable = fft_enable_delay;

    // divider input
        // ctr=0, div mode, ct1=1, product mode
    assign div_fft_real_in = (ctr_fft_data_sel) ? 32'd0 : fft_real_out;
    assign div_fft_imag_in = (ctr_fft_data_sel) ? 32'd0 : fft_imag_out;
    assign div_addr_in = (ctr_fft_data_sel) ? 10'd0 : fft_count_out;
    assign div_enable_in = (ctr_fft_data_sel) ? 1'd0 : fft_valid_out;
    
    // prodcut mode preprocess
    assign fft_real_in_product_mode = (ctr_fft_data_sel) ? fft_real_out : 32'd0;
    assign fft_imag_in_product_mode = (ctr_fft_data_sel) ? fft_imag_out : 32'd0;
    assign fft_count_product_mode = (ctr_fft_data_sel) ? fft_count_out : 10'd0;
    assign fft_valid_product_mode = (ctr_fft_data_sel) ? fft_valid_out : 1'd0;
    
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            fft_real_in_product_mode_delay1 <= 32'd0;
            fft_imag_in_product_mode_delay1 <= 32'd0;
            fft_count_product_mode_delay1 <= 10'd0;
            fft_valid_product_mode_delay1 <= 1'd0; 
        end else begin
            fft_real_in_product_mode_delay1 <= fft_real_in_product_mode;
            fft_imag_in_product_mode_delay1 <= fft_imag_in_product_mode;
            fft_count_product_mode_delay1 <= fft_count_product_mode;
            fft_valid_product_mode_delay1 <= fft_valid_product_mode; 
        end
    end

    // H_real
    assign H_real_CS = div_enable_out | fft_valid_out; // div_enable_out=1 => div ans sended into sram, fft_valid_out=1 => product 
    assign H_real_OE = fft_valid_product_mode_delay1;
    assign H_real_WEB = !div_enable_out;
    assign H_real_A = (ctr_fft_data_sel) ? fft_count_product_mode : div_addr_out ;
    assign H_real_DI = div_H_real_out;
    // H_Imag
    assign H_imag_CS = div_enable_out | fft_valid_out; // div_enable_out=1 => div ans sended into sram, fft_valid_out=1 => product 
    assign H_imag_OE = fft_valid_product_mode_delay1;
    assign H_imag_WEB = !div_enable_out;
    assign H_imag_A = (ctr_fft_data_sel) ? fft_count_product_mode : div_addr_out ;
    assign H_imag_DI = div_H_imag_out;

    // mul
    assign mul_a = fft_real_in_product_mode_delay1;
    assign mul_b = fft_imag_in_product_mode_delay1;
    assign mul_c = H_real_DO;
    assign mul_d = H_imag_DO;
    assign mul_addr = fft_count_product_mode_delay1;
    assign mul_enable = fft_valid_product_mode_delay1;
    
    // IFFT
    assign ifft_enable_in = mul_enable_out | ctr_ifft_en;
    assign ifft_real_in = mul_real_out;
    assign ifft_imag_in = mul_imag_out;

    // sram response
    logic sram1_OE_delay1;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            sram1_OE_delay1 <= 1'd0;
        end else begin
            sram1_OE_delay1 <= sram1_OE;
        end
    end
    assign sram_response_CS = sram1_OE | ifft_valid_out;
    assign sram_response_OE = sram1_OE_delay1;
    assign sram_response_WEB = !ifft_valid_out;
    assign sram_response_A = (ctr_sram1_addr_sel) ? ifft_counter_out : sram1_addr_in;
    assign sram_response_DI = ifft_real_out;
	assign ctr_instr = instr;

    assign response_DO = sram_response_DO;
    sram_1024_wrapper sram_fram(
        //input
        .CK(clk),
        .CS(sram_fram_CS),
        .OE(sram_fram_OE),
        .WEB(sram_fram_WEB),
        .A(sram_fram_A),
        .DI(sram_fram_DI),
        //output
        .DO(sram_fram_DO)
    );
    controller controller(
        //input
        .clk(clk),
        .rst(rst),
        .instr(ctr_instr),
        .fft_addr_out(fft_count_out),
        .div_addr_out(div_addr_out),
        .ifft_addr_out(ifft_counter_out),
        //output
        .sram0_addr_sel(ctr_sram0_addr_sel),
        .sram0_addr(ctr_sram0_addr),
        .sram_oe(ctr_sram_oe),
        .fft_data_sel(ctr_fft_data_sel), // 0: training mode, 1: product mode
        .fft_en(ctr_fft_en),
        .ifft_en(ctr_ifft_en),
        .sram1_addr_sel(ctr_sram1_addr_sel)
    );
    FFT_32_32 FFT_module(
        //input
        .enable(fft_enable),
        .clk(clk),
        .rst(rst),
        .real_in(fft_real_in),
        .image_in(fft_imag_in),
        //output
        .real_out(fft_real_out),
        .image_out(fft_imag_out),
        .count_out(fft_count_out),
        .valid_out(fft_valid_out)
    );
    divider_top div(
        //input
        .rst(rst),
        .clk(clk),
        .fft_real(div_fft_real_in),
        .fft_imag(div_fft_imag_in),
        .addr(div_addr_in),
        .enable(div_enable_in),
        //output
        .H_real(div_H_real_out),
        .H_imag(div_H_imag_out),
        .addr_out(div_addr_out),
        .enable_out(div_enable_out)
    );
    sram_1024_wrapper H_real(
        //input
        .CK(clk),
        .CS(H_real_CS),
        .OE(H_real_OE),
        .WEB(H_real_WEB),
        .A(H_real_A),
        .DI(H_real_DI),
        //output
        .DO(H_real_DO)
    );
    sram_1024_wrapper H_imag(
        //input
        .CK(clk),
        .CS(H_imag_CS),
        .OE(H_imag_OE),
        .WEB(H_imag_WEB),
        .A(H_imag_A),
        .DI(H_imag_DI),
        //output
        .DO(H_imag_DO)
    );
    complex_multiply mul(
        //input
        .clk(clk),
        .rst(rst),
        .a(mul_a),
        .b(mul_b),
        .c(mul_c),
        .d(mul_d),
        .addr(mul_addr),
        .enable(mul_enable),
        //output
        .real_out(mul_real_out),
        .img_out(mul_imag_out),
        .addr_out(mul_addr_out),
        .enable_out(mul_enable_out)
    );
    IFFT_32_32 IFFT(
        // input
        .enable(ifft_enable_in),
		.clk(clk),
		.rst(rst),
		.real_in(ifft_real_in),
		.image_in(ifft_imag_in),
		// output
        .real_out(ifft_real_out),
		.image_out(ifft_imag_out),
		.count_out(ifft_counter_out),
		.valid_out(ifft_valid_out)
    );

    sram_1024_wrapper sram_response(
        //input
        .CK(clk),
        .CS(sram_response_CS),
        .OE(sram_response_OE),
        .WEB(sram_response_WEB),
        .A(sram_response_A),
        .DI(sram_response_DI),
        //output
        .DO(sram_response_DO)
    );
endmodule