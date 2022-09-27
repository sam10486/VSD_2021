//`include "sign_process.sv"

module divider_preprocess (
    input clk,
    input rst,  
    input [31:0] A, //fft_real_in
    input [31:0] B, //fft_imag_in
    input [31:0] C, //filter
    input enable,
    input [9:0] addr,
    output logic [31:0] denominator_real,
    output logic [31:0] denominator_imag,
    output logic [31:0] numerator,
    output logic enable_out,
    output logic [9:0] addr_out
);
    logic sign_A, sign_B, sign_C;
    logic [31:0] A_out, B_out, C_out;
    sign_process sp_a(
        .D_in(A),
        .sign(sign_A),
        .D_out(A_out)
    );
    sign_process sp_b(
        .D_in(B),
        .sign(sign_B),
        .D_out(B_out)
    );
    sign_process sp_c(
        .D_in(C),
        .sign(sign_C),
        .D_out(C_out)
    );


    logic enable_tmp;
    logic [9:0] addr_tmp;
    assign addr_tmp = addr;
    assign enable_tmp = enable;

    logic [63:0] a_mul_c, b_mul_c;
    logic [63:0] A_sqr_plus_B_sqr;
    assign a_mul_c = A_out * C_out;
    assign b_mul_c = B_out * C_out;
    assign A_sqr_plus_B_sqr = (A_out * A_out) + (B_out * B_out); // denominator

    logic sign_real;
    assign sign_real = sign_A ^ sign_C;
    logic sign_imag;
    assign sign_imag = sign_B ^ sign_C ^ 1'b1;
    
    

    logic [63:0] a_mul_c_tmp, b_mul_c_tmp;
    logic [63:0] A_sqr_plus_B_sqr_tmp;
    logic sign_real_tmp, sign_imag_tmp;
    logic enable_tmp1;
    logic [9:0] addr_tmp1;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            a_mul_c_tmp <= 64'd0;
            b_mul_c_tmp <= 64'd0;
            A_sqr_plus_B_sqr_tmp <= 64'd0;
            sign_real_tmp <= 1'd0;
            sign_imag_tmp <= 1'd0;
            enable_tmp1 <= 1'd0;
            addr_tmp1 <= 10'd0;
        end else begin
            a_mul_c_tmp <= a_mul_c;
            b_mul_c_tmp <= b_mul_c;
            A_sqr_plus_B_sqr_tmp <= A_sqr_plus_B_sqr;
            sign_real_tmp <= sign_real;
            sign_imag_tmp <= sign_imag;
            enable_tmp1 <= enable_tmp;
            addr_tmp1 <= addr_tmp;
        end
    end

    logic [63:0] a_mul_c_process, b_mul_c_process;
    logic [63:0] A_sqr_plus_B_sqr_process;

    assign a_mul_c_process = (sign_real_tmp) ? ((a_mul_c_tmp - 64'd1) ^ 64'hffff_ffff_ffff_ffff) : a_mul_c_tmp;
    assign b_mul_c_process = (sign_imag_tmp) ? ((b_mul_c_tmp - 64'd1) ^ 64'hffff_ffff_ffff_ffff) : b_mul_c_tmp;
    
    logic [31:0] denominator_tmp_real, denominator_tmp_imag, numerator_tmp;
    assign denominator_tmp_real = a_mul_c_process[47:16];
    assign denominator_tmp_imag = b_mul_c_process[47:16];
    assign numerator_tmp = A_sqr_plus_B_sqr_tmp[47:16];
    
    always_ff @( posedge clk or posedge rst) begin
        if (rst) begin
            denominator_real <= 32'd0;
            denominator_imag <= 32'd0;
            numerator <= 32'd0;
            addr_out <= 10'd0;
            enable_out <= 1'd0;
        end else begin
            denominator_real <= denominator_tmp_real;
            denominator_imag <= denominator_tmp_imag;
            numerator <= numerator_tmp;
            addr_out <= addr_tmp1;
            enable_out <= enable_tmp1;
        end
    end
endmodule