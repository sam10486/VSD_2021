//`include "sign_process.sv"
module complex_multiply (
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    input [9:0] addr,
    input enable,
    output logic [31:0] real_out,
    output logic [31:0] img_out,
    output logic [9:0] addr_out,
    output logic enable_out
);
    
    logic [31:0] a_out, b_out, c_out, d_out;

    sign_process sp_a(
        .D_in(a),
        .sign(sign_a),
        .D_out(a_out)
    );
    sign_process sp_b(
        .D_in(b),
        .sign(sign_b),
        .D_out(b_out)
    );
    sign_process sp_c(
        .D_in(c),
        .sign(sign_c),
        .D_out(c_out)
    );
    sign_process sp_d(
        .D_in(d),
        .sign(sign_d),
        .D_out(d_out)
    );

    logic [63:0] a_mul_c, a_mul_c_pip0;
    logic [63:0] b_mul_d, b_mul_d_pip0;
    logic [63:0] b_mul_c, b_mul_c_pip0;
    logic [63:0] a_mul_d, a_mul_d_pip0;

    logic sign_a_pip0;
    logic sign_b_pip0;
    logic sign_c_pip0;
    logic sign_d_pip0;
    logic [9:0] addr_pip0;
    logic enable_pip0;

    assign a_mul_c = a_out * c_out;
    assign b_mul_d = b_out * d_out;
    assign b_mul_c = b_out * c_out;
    assign a_mul_d = a_out * d_out;


    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            a_mul_c_pip0 <= 64'd0;
            b_mul_d_pip0 <= 64'd0;
            b_mul_c_pip0 <= 64'd0;
            a_mul_d_pip0 <= 64'd0;
            sign_a_pip0 <= 1'd0;
            sign_b_pip0 <= 1'd0;
            sign_c_pip0 <= 1'd0;
            sign_d_pip0 <= 1'd0;
            addr_pip0 <= 10'd0;
            enable_pip0 <= 1'b0;
        end else begin
            a_mul_c_pip0 <= a_mul_c;
            b_mul_d_pip0 <= b_mul_d;
            b_mul_c_pip0 <= b_mul_c;
            a_mul_d_pip0 <= a_mul_d;
            sign_a_pip0 <= sign_a;
            sign_b_pip0 <= sign_b;
            sign_c_pip0 <= sign_c;
            sign_d_pip0 <= sign_d;
            addr_pip0 <= addr;
            enable_pip0 <= enable;
        end
    end

    logic sign_a_mul_c;
    logic sign_b_mul_d;
    logic sign_b_mul_c;
    logic sign_a_mul_d;
	
	assign sign_a_mul_c = sign_a_pip0 ^ sign_c_pip0;
	assign sign_b_mul_d = sign_b_pip0 ^ sign_d_pip0;
	assign sign_b_mul_c = sign_b_pip0 ^ sign_c_pip0;
	assign sign_a_mul_d = sign_a_pip0 ^ sign_d_pip0;
	


    logic [63:0] a_mul_c_process;
    logic [63:0] b_mul_d_process;
    logic [63:0] b_mul_c_process;
    logic [63:0] a_mul_d_process;


    assign a_mul_c_process = (sign_a_mul_c) ? ((a_mul_c_pip0 - 64'd1) ^ 64'hffffffffffffffff) : a_mul_c_pip0;
    assign b_mul_d_process = (sign_b_mul_d) ? ((b_mul_d_pip0 - 64'd1) ^ 64'hffffffffffffffff) : b_mul_d_pip0;
    assign b_mul_c_process = (sign_b_mul_c) ? ((b_mul_c_pip0 - 64'd1) ^ 64'hffffffffffffffff) : b_mul_c_pip0;
    assign a_mul_d_process = (sign_a_mul_d) ? ((a_mul_d_pip0 - 64'd1) ^ 64'hffffffffffffffff) : a_mul_d_pip0;
  

    logic [31:0] real_out_tmp;
    logic [31:0] img_out_tmp;

    assign real_out_tmp = a_mul_c_process[47:16] - b_mul_d_process[47:16];
    assign img_out_tmp = b_mul_c_process[47:16] + a_mul_d_process[47:16];


    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            real_out <= 32'd0;
            img_out <= 32'd0;
            addr_out <= 10'd0;
            enable_out <= 1'b0;
        end else begin
            real_out <= real_out_tmp;
            img_out <= img_out_tmp;
            addr_out <= addr_pip0;
            enable_out <= enable_pip0;
        end
    end

endmodule