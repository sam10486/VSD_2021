
module Register_file (
    input logic [4:0] Read_reg1, Read_reg2, Write_reg,
    input logic [31:0] Write_data,
    input logic Reg_write,
    input logic clk, rst,
    output logic [31:0] Read_data1, Read_data2
);

logic [31:0] Register [0:31];

always @(posedge clk or posedge rst) begin
    if (rst) begin:for_local
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            Register[i] <= 32'd0;
        end
    end 
    else begin
        if (Reg_write) begin
            if (Write_reg != 5'd0) begin
                Register[Write_reg] <= Write_data;
            end else begin
                Register[0] <= 32'd0;
            end
        end
    end
end

 
always_comb begin
    if ((Read_reg1 == Write_reg) && Reg_write) begin
        Read_data1 = Write_data;
    end else begin
        Read_data1 = Register[Read_reg1];
    end
    if ((Read_reg2 == Write_reg) && Reg_write) begin
        Read_data2 = Write_data;
    end else begin
        Read_data2 = Register[Read_reg2];
    end 
end

endmodule