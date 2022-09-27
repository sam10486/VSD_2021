`timescale 1ns / 1ps
`include "divider.sv"   
module divider_tb();
    reg rst;
    reg clk;
    reg [31:0] A;
    reg [31:0] B;
    reg [9:0] addr;
    reg enable;
    wire [31:0] C;
    wire [9:0] addr_out;
    wire enable_out;
    reg [10:0] cnt;

    divider div(
      .rst(rst), 
      .clk(clk),
      .A(A),
      .B(B),
      .addr(addr),
      .enable(enable),
      .C(C),
      .addr_out(addr_out),
      .enable_out(enable_out)
    );
    
    
    integer fr0;
    integer fr1;

    integer fd0;


    initial begin
      clk = 1'b0;
      rst = 1'b1;
      enable = 1'b0;
      A = 32'd0;
      B = 32'd0;
      # 20
      rst = 1'b0;
      cnt = 10'd0;
     

      fr0 = $fopen("A.txt", "r");
      fr1 = $fopen("B.txt", "r");

      fd0 = $fopen("verify/div_ans.txt", "w");
      #100000
      $fclose(fd0);
    end

    always #5 clk = ~clk;

    always_ff @(posedge clk) begin
        integer i; 
        integer j;  
        i = $fscanf(fr0, "%d", A);
        j = $fscanf(fr1, "%d", B);
    end

    always @(posedge clk) begin
      cnt <= cnt + 1'd1;
      //#325
      if (rst == 0 && cnt > 10'd100) begin
        $fwrite(fd0, "%d\n", C);
      end
    end



    initial begin
      $dumpfile("div.vcd");
      $dumpvars;
    end
endmodule