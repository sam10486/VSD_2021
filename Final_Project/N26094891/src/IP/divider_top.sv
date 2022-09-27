`include "divider.sv"
`include "divider_preprocess.sv"
`include "ground_truth_array.sv"
module divider_top (
    input rst,
    input clk,
    input [31:0] fft_real,
    input [31:0] fft_imag,
    input [9:0] addr,
    input enable,
    output logic [31:0] H_real,
    output logic [31:0] H_imag,
    output logic [9:0] addr_out,
    output logic enable_out
);


    logic [31:0] ground_truth_out;
    ground_truth_array gt(
        .re(enable),
        .addr(addr),
        .gt_real_out(ground_truth_out)
    );

    logic [31:0] fft_real_pip, fft_imag_pip;
    logic [9:0] addr_pip;
    logic enable_pip;
    logic [31:0] ground_truth_pip_real;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            fft_real_pip <= 32'd0;
            fft_imag_pip <= 32'd0;
            addr_pip <= 10'd0;
            enable_pip <= 1'd0;
            ground_truth_pip_real <= 32'd0;
        end else begin
            fft_real_pip <= fft_real;
            fft_imag_pip <= fft_imag;
            addr_pip <= addr;
            enable_pip <= enable;
            ground_truth_pip_real <= ground_truth_out;
        end
    end

    logic [31:0] A_preprocess_real, A_preprocess_imag, B_preprocess;
    logic [9:0] addr_preprocess;
    logic enable_preprocess;
    divider_preprocess dp(
        .clk(clk),
        .rst(rst),
        .A(fft_real_pip),
        .B(fft_imag_pip),
        .C(ground_truth_pip_real),
        .enable(enable_pip),
        .addr(addr_pip),
        .denominator_real(A_preprocess_real),
        .denominator_imag(A_preprocess_imag),
        .numerator(B_preprocess),
        .enable_out(enable_preprocess),
        .addr_out(addr_preprocess)
    );
    
    logic enable_out_imag;
    logic [9:0] addr_out_imag;
    // process real part
    divider dv1(
        .clk(clk),
        .rst(rst),
        .A(A_preprocess_real),
        .B(B_preprocess),
        .enable(enable_preprocess),
        .addr(addr_preprocess),
        .C(H_real),
        .enable_out(enable_out),
        .addr_out(addr_out)
    );
    // process imag part
    divider dv2(
        .clk(clk),
        .rst(rst),
        .A(A_preprocess_imag),
        .B(B_preprocess),
        .enable(enable_preprocess),
        .addr(addr_preprocess),
        .C(H_imag),
        .enable_out(enable_out_imag),
        .addr_out(addr_out_imag)
    );
endmodule