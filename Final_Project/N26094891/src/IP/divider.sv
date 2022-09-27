`include "divide_unit.sv"
//`include "sign_process.sv"
module divider (
    input clk,
    input rst,
    // A/B=C..D
    input [31:0] A, 
    input [31:0] B,
    input enable,
    input [9:0] addr,
    output logic [31:0] C,
    output logic enable_out,
    output logic [9:0] addr_out
);

    logic [31:0] A_out, B_out;
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
    
    logic [9:0] addr_tmp;
    logic enable_tmp;

    assign addr_tmp = addr;
    assign enable_tmp = enable;

    logic [31:0] reg0_A;
    logic [31:0] reg0_B;
    logic reg0_sign;
    logic [9:0] addr_reg0;
    logic enable_reg0;
    //0-th pip
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg0_A <= 32'd0;
            reg0_B <= 32'd0;
            reg0_sign <= 1'd0;
            addr_reg0 <= 10'd0;
            enable_reg0 <= 1'd0;
        end else begin
            reg0_A <= A_out;
            reg0_B <= B_out;
            reg0_sign <= (sign_A ^ sign_B);
            addr_reg0 <= addr_tmp;
            enable_reg0 <= enable_tmp;
        end
    end

    logic [31:0] pip0_D;
    logic pip0_C;
    divide_unit du0(
        .A({14'd0,reg0_A[31:14]}),
        .B(reg0_B),
        .D(pip0_D),
        .C(pip0_C)
    );

    //1-th pip
    logic [31:0] reg1_A;
    logic [31:0] reg1_B;
    logic [31:0] reg1_D;
    logic [1:0] reg1_C;
    logic reg1_sign;
    logic [9:0] addr_reg1;
    logic enable_reg1;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg1_A <= 32'd0;
            reg1_B <= 32'd0;
            reg1_D <= 32'd0;
            reg1_C <= 2'd0;
            reg1_sign <= 1'd0;
            addr_reg1 <= 10'd0;
            enable_reg1 <= 1'd0;
        end else begin
            reg1_A <= reg0_A;
            reg1_B <= reg0_B;
            reg1_D <= pip0_D;
            reg1_C <= {1'd0, pip0_C};
            reg1_sign <= reg0_sign;
            addr_reg1 <= addr_reg0;
            enable_reg1 <= enable_reg0;
        end
    end

    logic [31:0] pip1_D;
    logic pip1_C;
    divide_unit du1(
        .A({reg1_D[30:0], reg1_A[13]}),
        .B(reg1_B),
        .D(pip1_D),
        .C(pip1_C)

    );
    //2-th pip
    logic [31:0] reg2_A;
    logic [31:0] reg2_B;
    logic [31:0] reg2_D;
    logic [2:0] reg2_C;
    logic reg2_sign;
    logic [9:0] addr_reg2;
    logic enable_reg2;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg2_A <= 32'd0;
            reg2_B <= 32'd0;
            reg2_D <= 32'd0;
            reg2_C <= 3'd0;
            reg2_sign <= 1'd0;
            addr_reg2 <= 10'd0;
            enable_reg2 <= 1'd0;
        end else begin
            reg2_A <= reg1_A;
            reg2_B <= reg1_B;
            reg2_D <= pip1_D;
            reg2_C <= {reg1_C, pip1_C};
            reg2_sign <= reg1_sign;
            addr_reg2 <= addr_reg1;
            enable_reg2 <= enable_reg1;
        end
    end

    logic [31:0] pip2_D;
    logic pip2_C;
    divide_unit du2(
        .A({reg2_D[30:0], reg2_A[12]}),
        .B(reg2_B),
        .D(pip2_D),
        .C(pip2_C)

    );
    //3-th pip
    logic [31:0] reg3_A;
    logic [31:0] reg3_B;
    logic [31:0] reg3_D;
    logic [3:0] reg3_C;
    logic reg3_sign;
    logic [9:0] addr_reg3;
    logic enable_reg3;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg3_A <= 32'd0;
            reg3_B <= 32'd0;
            reg3_D <= 32'd0;
            reg3_C <= 4'd0;
            reg3_sign <= 1'd0;
            addr_reg3 <= 10'd0;
            enable_reg3 <= 1'd0;
        end else begin
            reg3_A <= reg2_A;
            reg3_B <= reg2_B;
            reg3_D <= pip2_D;
            reg3_C <= {reg2_C, pip2_C};
            reg3_sign <= reg2_sign;
            addr_reg3 <= addr_reg2;
            enable_reg3 <= enable_reg2;
        end
    end

    logic [31:0] pip3_D;
    logic pip3_C;
    divide_unit du3(
        .A({reg3_D[30:0], reg3_A[11]}),
        .B(reg3_B),
        .D(pip3_D),
        .C(pip3_C)

    );
    //4-th pip
    logic [31:0] reg4_A;
    logic [31:0] reg4_B;
    logic [31:0] reg4_D;
    logic [4:0] reg4_C;
    logic reg4_sign;
    logic [9:0] addr_reg4;
    logic enable_reg4;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg4_A <= 32'd0;
            reg4_B <= 32'd0;
            reg4_D <= 32'd0;
            reg4_C <= 5'd0;
            reg4_sign <= 1'd0;
            addr_reg4 <= 10'd0;
            enable_reg4 <= 1'd1;
        end else begin
            reg4_A <= reg3_A;
            reg4_B <= reg3_B;
            reg4_D <= pip3_D;
            reg4_C <= {reg3_C, pip3_C};
            reg4_sign <= reg3_sign;
            addr_reg4 <= addr_reg3;
            enable_reg4 <= enable_reg3;
        end
    end

    logic [31:0] pip4_D;
    logic pip4_C;
    divide_unit du4(
        .A({reg4_D[30:0], reg4_A[10]}),
        .B(reg4_B),
        .D(pip4_D),
        .C(pip4_C)

    );
    //5-th pip
    logic [31:0] reg5_A;
    logic [31:0] reg5_B;
    logic [31:0] reg5_D;
    logic [5:0] reg5_C;
    logic reg5_sign;
    logic [9:0] addr_reg5;
    logic enable_reg5;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg5_A <= 32'd0;
            reg5_B <= 32'd0;
            reg5_D <= 32'd0;
            reg5_C <= 6'd0;
            reg5_sign <= 1'd0;
            addr_reg5 <= 10'd0;
            enable_reg5 <= 1'd0;
        end else begin
            reg5_A <= reg4_A;
            reg5_B <= reg4_B;
            reg5_D <= pip4_D;
            reg5_C <= {reg4_C, pip4_C};
            reg5_sign <= reg4_sign;
            addr_reg5 <= addr_reg4;
            enable_reg5 <= enable_reg4;
        end
    end

    logic [31:0] pip5_D;
    logic pip5_C;
    divide_unit du5(
        .A({reg5_D[30:0], reg5_A[9]}),
        .B(reg5_B),
        .D(pip5_D),
        .C(pip5_C)
    );
    //6-th pip
    logic [31:0] reg6_A;
    logic [31:0] reg6_B;
    logic [31:0] reg6_D;
    logic [6:0] reg6_C;
    logic reg6_sign;
    logic [9:0] addr_reg6;
    logic enable_reg6;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg6_A <= 32'd0;
            reg6_B <= 32'd0;
            reg6_D <= 32'd0;
            reg6_C <= 7'd0;
            reg6_sign <= 1'd0;
            addr_reg6 <= 10'd0;
            enable_reg6 <= 1'd0;
        end else begin
            reg6_A <= reg5_A;
            reg6_B <= reg5_B;
            reg6_D <= pip5_D;
            reg6_C <= {reg5_C, pip5_C};
            reg6_sign <= reg5_sign;
            addr_reg6 <= addr_reg5;
            enable_reg6 <= enable_reg5;
        end
    end

    logic [31:0] pip6_D;
    logic pip6_C;
    divide_unit du6(
        .A({reg6_D[30:0], reg6_A[8]}),
        .B(reg6_B),
        .D(pip6_D),
        .C(pip6_C)

    );
    //7-th pip
    logic [31:0] reg7_A;
    logic [31:0] reg7_B;
    logic [31:0] reg7_D;
    logic [7:0] reg7_C;
    logic reg7_sign;
    logic [9:0] addr_reg7;
    logic enable_reg7;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg7_A <= 32'd0;
            reg7_B <= 32'd0;
            reg7_D <= 32'd0;
            reg7_C <= 8'd0;
            reg7_sign <= 1'd0;
            addr_reg7 <= 10'd0;
            enable_reg7 <= 1'd0;
        end else begin
            reg7_A <= reg6_A;
            reg7_B <= reg6_B;
            reg7_D <= pip6_D;
            reg7_C <= {reg6_C, pip6_C};
            reg7_sign <= reg6_sign;
            addr_reg7 <= addr_reg6;
            enable_reg7 <= enable_reg6;
        end
    end

    logic [31:0] pip7_D;
    logic pip7_C;
    divide_unit du7(
        .A({reg7_D[30:0], reg7_A[7]}),
        .B(reg7_B),
        .D(pip7_D),
        .C(pip7_C)
    );

    //8-th pip
    logic [31:0] reg8_A;
    logic [31:0] reg8_B;
    logic [31:0] reg8_D;
    logic [8:0] reg8_C;
    logic reg8_sign;
    logic [9:0] addr_reg8;
    logic enable_reg8;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg8_A <= 32'd0;
            reg8_B <= 32'd0;
            reg8_D <= 32'd0;
            reg8_C <= 9'd0;
            reg8_sign <= 1'd0;
            addr_reg8 <= 10'd0;
            enable_reg8 <= 1'd0;
        end else begin
            reg8_A <= reg7_A;
            reg8_B <= reg7_B;
            reg8_D <= pip7_D;
            reg8_C <= {reg7_C, pip7_C};
            reg8_sign <= reg7_sign;
            addr_reg8 <= addr_reg7;
            enable_reg8 <= enable_reg7;
        end
    end

    logic [31:0] pip8_D;
    logic pip8_C;
    divide_unit du8(
        .A({reg8_D[30:0], reg8_A[6]}),
        .B(reg8_B),
        .D(pip8_D),
        .C(pip8_C)
    );
    //9-th pip
    logic [31:0] reg9_A;
    logic [31:0] reg9_B;
    logic [31:0] reg9_D;
    logic [9:0] reg9_C;
    logic reg9_sign;
    logic [9:0] addr_reg9;
    logic enable_reg9;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg9_A <= 32'd0;
            reg9_B <= 32'd0;
            reg9_D <= 32'd0;
            reg9_C <= 10'd0;
            reg9_sign <= 1'd0;
            addr_reg9 <= 10'd0;
            enable_reg9 <= 1'd0;
        end else begin
            reg9_A <= reg8_A;
            reg9_B <= reg8_B;
            reg9_D <= pip8_D;
            reg9_C <= {reg8_C, pip8_C};
            reg9_sign <= reg8_sign;
            addr_reg9 <= addr_reg8;
            enable_reg9 <= enable_reg8;
        end
    end

    logic [31:0] pip9_D;
    logic pip9_C;
    divide_unit du9(
        .A({reg9_D[30:0], reg9_A[5]}),
        .B(reg9_B),
        .D(pip9_D),
        .C(pip9_C)
    );
    //10-th pip
    logic [31:0] reg10_A;
    logic [31:0] reg10_B;
    logic [31:0] reg10_D;
    logic [10:0] reg10_C;
    logic reg10_sign;
    logic [9:0] addr_reg10;
    logic enable_reg10;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg10_A <= 32'd0;
            reg10_B <= 32'd0;
            reg10_D <= 32'd0;
            reg10_C <= 11'd0;
            reg10_sign <= 1'd0;
            addr_reg10 <= 10'd0;
            enable_reg10 <= 1'd0;
        end else begin
            reg10_A <= reg9_A;
            reg10_B <= reg9_B;
            reg10_D <= pip9_D;
            reg10_C <= {reg9_C, pip9_C};
            reg10_sign <= reg9_sign;
            addr_reg10 <= addr_reg9;
            enable_reg10 <= enable_reg9;
        end
    end

    logic [31:0] pip10_D;
    logic pip10_C;
    divide_unit du10(
        .A({reg10_D[30:0], reg10_A[4]}),
        .B(reg10_B),
        .D(pip10_D),
        .C(pip10_C)
    );
    //11-th pip
    logic [31:0] reg11_A;
    logic [31:0] reg11_B;
    logic [31:0] reg11_D;
    logic [11:0] reg11_C;
    logic reg11_sign;
    logic [9:0] addr_reg11;
    logic enable_reg11;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg11_A <= 32'd0;
            reg11_B <= 32'd0;
            reg11_D <= 32'd0;
            reg11_C <= 12'd0;
            reg11_sign <= 1'd0;
            addr_reg11 <= 10'd0;;
            enable_reg11 <= 1'd0;
        end else begin
            reg11_A <= reg10_A;
            reg11_B <= reg10_B;
            reg11_D <= pip10_D;
            reg11_C <= {reg10_C, pip10_C};
            reg11_sign <= reg10_sign;
            addr_reg11 <= addr_reg10;
            enable_reg11 <= enable_reg10;
        end
    end

    logic [31:0] pip11_D;
    logic pip11_C;
    divide_unit du11(
        .A({reg11_D[30:0], reg11_A[3]}),
        .B(reg11_B),
        .D(pip11_D),
        .C(pip11_C)
    );
    //12-th pip
    logic [31:0] reg12_A;
    logic [31:0] reg12_B;
    logic [31:0] reg12_D;
    logic [12:0] reg12_C;
    logic reg12_sign;
    logic [9:0] addr_reg12;
    logic enable_reg12;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg12_A <= 32'd0;
            reg12_B <= 32'd0;
            reg12_D <= 32'd0;
            reg12_C <= 13'd0;
            reg12_sign <= 1'd0;
            addr_reg12 <= 10'd0;
            enable_reg12 <= 1'd0;
            
        end else begin
            reg12_A <= reg11_A;
            reg12_B <= reg11_B;
            reg12_D <= pip11_D;
            reg12_C <= {reg11_C, pip11_C};
            reg12_sign <= reg11_sign;
            addr_reg12 <= addr_reg11;
            enable_reg12 <= enable_reg11;
        end
    end

    logic [31:0] pip12_D;
    logic pip12_C;
    divide_unit du12(
        .A({reg12_D[30:0], reg12_A[2]}),
        .B(reg12_B),
        .D(pip12_D),
        .C(pip12_C)
    );
    //13-th pip
    logic [31:0] reg13_A;
    logic [31:0] reg13_B;
    logic [31:0] reg13_D;
    logic [13:0] reg13_C;
    logic reg13_sign;
    logic [9:0] addr_reg13;
    logic enable_reg13;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg13_A <= 32'd0;
            reg13_B <= 32'd0;
            reg13_D <= 32'd0;
            reg13_C <= 14'd0;
            reg13_sign <= 1'd0;
            addr_reg13 <= 10'd0;
            enable_reg13 <= 1'd0;
        end else begin
            reg13_A <= reg12_A;
            reg13_B <= reg12_B;
            reg13_D <= pip12_D;
            reg13_C <= {reg12_C, pip12_C};
            reg13_sign <= reg12_sign;
            addr_reg13 <= addr_reg12;
            enable_reg13 <= enable_reg12;
        end
    end

    logic [31:0] pip13_D;
    logic pip13_C;
    divide_unit du13(
        .A({reg13_D[30:0], reg13_A[1]}),
        .B(reg13_B),
        .D(pip13_D),
        .C(pip13_C)
    );
    //14-th pip
    logic [31:0] reg14_A;
    logic [31:0] reg14_B;
    logic [31:0] reg14_D;
    logic [14:0] reg14_C;
    logic reg14_sign;
    logic [9:0] addr_reg14;
    logic enable_reg14;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg14_A <= 32'd0;
            reg14_B <= 32'd0;
            reg14_D <= 32'd0;
            reg14_C <= 15'd0;
            reg14_sign <= 1'd0;
            addr_reg14 <= 10'd0;
            enable_reg14 <= 1'd0;
        end else begin
            reg14_A <= reg13_A;
            reg14_B <= reg13_B;
            reg14_D <= pip13_D;
            reg14_C <= {reg13_C, pip13_C};
            reg14_sign <= reg13_sign;
            addr_reg14 <= addr_reg13;
            enable_reg14 <=  enable_reg13;
        end
    end

    logic [31:0] pip14_D;
    logic pip14_C;
    divide_unit du14(
        .A({reg14_D[30:0], reg14_A[0]}),
        .B(reg14_B),
        .D(pip14_D),
        .C(pip14_C)
    );
    //15-th pip
    logic [31:0] reg15_A;
    logic [31:0] reg15_B;
    logic [31:0] reg15_D;
    logic [15:0] reg15_C;
    logic reg15_sign;
    logic [9:0] addr_reg15;
    logic enable_reg15;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg15_A <= 32'd0;
            reg15_B <= 32'd0;
            reg15_D <= 32'd0;
            reg15_C <= 16'd0;
            reg15_sign <= 1'd0;
            addr_reg15 <= 10'd0;
            enable_reg15 <= 1'd0;
        end else begin
            reg15_A <= reg14_A;
            reg15_B <= reg14_B;
            reg15_D <= pip14_D;
            reg15_C <= {reg14_C, pip14_C};
            reg15_sign <= reg14_sign;
            addr_reg15 <= addr_reg14;
            enable_reg15 <= enable_reg14;
        end
    end

    logic [31:0] pip15_D;
    logic pip15_C;
    divide_unit du15(
        .A({reg15_D[30:0], 1'b0}),
        .B(reg15_B),
        .D(pip15_D),
        .C(pip15_C)
    );
    //16-th pip
    logic [31:0] reg16_A;
    logic [31:0] reg16_B;
    logic [31:0] reg16_D;
    logic [16:0] reg16_C;
    logic reg16_sign;
    logic [9:0] addr_reg16;
    logic enable_reg16;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg16_A <= 32'd0;
            reg16_B <= 32'd0;
            reg16_D <= 32'd0;
            reg16_C <= 17'd0;
            reg16_sign <= 1'd0;
            addr_reg16 <= 10'd0;
            enable_reg16 <= 1'd0;
        end else begin
            reg16_A <= reg15_A;
            reg16_B <= reg15_B;
            reg16_D <= pip15_D;
            reg16_C <= {reg15_C, pip15_C};
            reg16_sign <= reg15_sign;
            addr_reg16 <= addr_reg15;
            enable_reg16 <= enable_reg15;
        end
    end

    logic [31:0] pip16_D;
    logic pip16_C;
    divide_unit du16(
        .A({reg16_D[30:0], 1'b0}),
        .B(reg16_B),
        .D(pip16_D),
        .C(pip16_C)
    );
    //17-th pip
    logic [31:0] reg17_A;
    logic [31:0] reg17_B;
    logic [31:0] reg17_D;
    logic [17:0] reg17_C;
    logic reg17_sign;
    logic [9:0] addr_reg17;
    logic enable_reg17;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg17_A <= 32'd0;
            reg17_B <= 32'd0;
            reg17_D <= 32'd0;
            reg17_C <= 18'd0;
            reg17_sign <= 1'd0;
            addr_reg17 <= 10'd0;
            enable_reg17 <= 1'd0;
        end else begin
            reg17_A <= reg16_A;
            reg17_B <= reg16_B;
            reg17_D <= pip16_D;
            reg17_C <= {reg16_C, pip16_C};
            reg17_sign <= reg16_sign;
            addr_reg17 <= addr_reg16;
            enable_reg17 <= enable_reg16;
        end
    end

    logic [31:0] pip17_D;
    logic pip17_C;
    divide_unit du17(
        .A({reg17_D[30:0], 1'b0}),
        .B(reg17_B),
        .D(pip17_D),
        .C(pip17_C)
    );
    //18-th pip
    logic [31:0] reg18_A;
    logic [31:0] reg18_B;
    logic [31:0] reg18_D;
    logic [18:0] reg18_C;
    logic reg18_sign;
    logic [9:0] addr_reg18;
    logic enable_reg18;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg18_A <= 32'd0;
            reg18_B <= 32'd0;
            reg18_D <= 32'd0;
            reg18_C <= 19'd0;
            reg18_sign <= 1'd0;
            addr_reg18 <= 10'd0;
            enable_reg18 <= 1'd0;
        end else begin
            reg18_A <= reg17_A;
            reg18_B <= reg17_B;
            reg18_D <= pip17_D;
            reg18_C <= {reg17_C, pip17_C};
            reg18_sign <= reg17_sign;
            addr_reg18 <= addr_reg17;
            enable_reg18 <= enable_reg17;
        end
    end

    logic [31:0] pip18_D;
    logic pip18_C;
    divide_unit du18(
        .A({reg18_D[30:0], 1'b0}),
        .B(reg18_B),
        .D(pip18_D),
        .C(pip18_C)
    );
    //19-th pip
    logic [31:0] reg19_A;
    logic [31:0] reg19_B;
    logic [31:0] reg19_D;
    logic [19:0] reg19_C;
    logic reg19_sign;
    logic [9:0] addr_reg19;
    logic enable_reg19;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg19_A <= 32'd0;
            reg19_B <= 32'd0;
            reg19_D <= 32'd0;
            reg19_C <= 20'd0;
            reg19_sign <= 1'd0;
            addr_reg19 <= 10'd0;
            enable_reg19 <= 1'd0;
        end else begin
            reg19_A <= reg18_A;
            reg19_B <= reg18_B;
            reg19_D <= pip18_D;
            reg19_C <= {reg18_C, pip18_C};
            reg19_sign <= reg18_sign;
            addr_reg19 <= addr_reg18;
            enable_reg19 <= enable_reg18;
        end
    end

    logic [31:0] pip19_D;
    logic pip19_C;
    divide_unit du19(
        .A({reg19_D[30:0], 1'b0}),
        .B(reg19_B),
        .D(pip19_D),
        .C(pip19_C)
    );
    //20-th pip
    logic [31:0] reg20_A;
    logic [31:0] reg20_B;
    logic [31:0] reg20_D;
    logic [20:0] reg20_C;
    logic reg20_sign;
    logic [9:0] addr_reg20;
    logic enable_reg20;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg20_A <= 32'd0;
            reg20_B <= 32'd0;
            reg20_D <= 32'd0;
            reg20_C <= 21'd0;
            reg20_sign <= 1'd0;
            addr_reg20 <= 10'd0;
            enable_reg20 <= 1'd0;
        end else begin
            reg20_A <= reg19_A;
            reg20_B <= reg19_B;
            reg20_D <= pip19_D;
            reg20_C <= {reg19_C, pip19_C};
            reg20_sign <= reg19_sign;
            addr_reg20 <= addr_reg19;
            enable_reg20 <= enable_reg19;
        end
    end

    logic [31:0] pip20_D;
    logic pip20_C;
    divide_unit du20(
        .A({reg20_D[30:0], 1'b0}),
        .B(reg20_B),
        .D(pip20_D),
        .C(pip20_C)
    );
    //21-th pip
    logic [31:0] reg21_A;
    logic [31:0] reg21_B;
    logic [31:0] reg21_D;
    logic [21:0] reg21_C;
    logic reg21_sign;
    logic [9:0] addr_reg21;
    logic enable_reg21;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg21_A <= 32'd0;
            reg21_B <= 32'd0;
            reg21_D <= 32'd0;
            reg21_C <= 22'd0;
            reg21_sign <= 1'd0;
            addr_reg21 <= 10'd0;
            enable_reg21 <= 1'd0;
        end else begin
            reg21_A <= reg20_A;
            reg21_B <= reg20_B;
            reg21_D <= pip20_D;
            reg21_C <= {reg20_C, pip20_C};
            reg21_sign <= reg20_sign;
            addr_reg21 <= addr_reg20;
            enable_reg21 <= enable_reg20;
        end
    end

    logic [31:0] pip21_D;
    logic pip21_C;
    divide_unit du21(
        .A({reg21_D[30:0], 1'b0}),
        .B(reg21_B),
        .D(pip21_D),
        .C(pip21_C)
    );
    //22-th pip
    logic [31:0] reg22_A;
    logic [31:0] reg22_B;
    logic [31:0] reg22_D;
    logic [22:0] reg22_C;
    logic reg22_sign;
    logic [9:0] addr_reg22;
    logic enable_reg22;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg22_A <= 32'd0;
            reg22_B <= 32'd0;
            reg22_D <= 32'd0;
            reg22_C <= 23'd0;
            reg22_sign <= 1'd0;
            addr_reg22 <= 10'd0;
            enable_reg22 <= 1'd0;
        end else begin
            reg22_A <= reg21_A;
            reg22_B <= reg21_B;
            reg22_D <= pip21_D; 
            reg22_C <= {reg21_C, pip21_C};
            reg22_sign <= reg21_sign;
            addr_reg22 <= addr_reg21;
            enable_reg22 <= enable_reg21;
        end
    end

    logic [31:0] pip22_D;
    logic pip22_C;
    divide_unit du22(
        .A({reg22_D[30:0], 1'b0}),
        .B(reg22_B),
        .D(pip22_D),
        .C(pip22_C)
    );
    //23-th pip
    logic [31:0] reg23_A;
    logic [31:0] reg23_B;
    logic [31:0] reg23_D;
    logic [23:0] reg23_C;
    logic reg23_sign;
    logic [9:0] addr_reg23;
    logic enable_reg23;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg23_A <= 32'd0;
            reg23_B <= 32'd0;
            reg23_D <= 32'd0;
            reg23_C <= 24'd0;
            reg23_sign <= 1'd0;
            addr_reg23 <= 10'd0;
            enable_reg23 <= 1'd0;
        end else begin
            reg23_A <= reg22_A;
            reg23_B <= reg22_B;
            reg23_D <= pip22_D;
            reg23_C <= {reg22_C, pip22_C};
            reg23_sign <= reg22_sign;
            addr_reg23 <= addr_reg22;
            enable_reg23 <= enable_reg22;
        end
    end

    logic [31:0] pip23_D;
    logic pip23_C;
    divide_unit du23(
        .A({reg23_D[30:0], 1'b0}),
        .B(reg23_B),
        .D(pip23_D),
        .C(pip23_C)
    );
    //24-th pip
    logic [31:0] reg24_A;
    logic [31:0] reg24_B;
    logic [31:0] reg24_D;
    logic [24:0] reg24_C;
    logic reg24_sign;
    logic [9:0] addr_reg24;
    logic enable_reg24;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg24_A <= 32'd0;
            reg24_B <= 32'd0;
            reg24_D <= 32'd0;
            reg24_C <= 25'd0;
            reg24_sign <= 1'd0;
            addr_reg24 <= 10'd0;
            enable_reg24 <= 1'd0;
        end else begin
            reg24_A <= reg23_A;
            reg24_B <= reg23_B;
            reg24_D <= pip23_D;
            reg24_C <= {reg23_C, pip23_C};
            reg24_sign <= reg23_sign;
            addr_reg24 <= addr_reg23;
            enable_reg24 <= enable_reg23;
        end
    end

    logic [31:0] pip24_D;
    logic pip24_C;
    divide_unit du24(
        .A({reg24_D[30:0], 1'b0}),
        .B(reg24_B),
        .D(pip24_D),
        .C(pip24_C)
    );
    //25-th pip
    logic [31:0] reg25_A;
    logic [31:0] reg25_B;
    logic [31:0] reg25_D;
    logic [25:0] reg25_C;
    logic reg25_sign;
    logic [9:0] addr_reg25;
    logic enable_reg25;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg25_A <= 32'd0;
            reg25_B <= 32'd0;
            reg25_D <= 32'd0;
            reg25_C <= 26'd0;
            reg25_sign <= 1'd0;
            addr_reg25 <= 10'd0;
            enable_reg25 <= 1'd0;
        end else begin
            reg25_A <= reg24_A;
            reg25_B <= reg24_B;
            reg25_D <= pip24_D;
            reg25_C <= {reg24_C, pip24_C};
            reg25_sign <= reg24_sign;
            addr_reg25 <= addr_reg24;
            enable_reg25 <= enable_reg24;
        end
    end

    logic [31:0] pip25_D;
    logic pip25_C;
    divide_unit du25(
        .A({reg25_D[30:0], 1'b0}),
        .B(reg25_B),
        .D(pip25_D),
        .C(pip25_C)
    );
    //26-th pip
    logic [31:0] reg26_A;
    logic [31:0] reg26_B;
    logic [31:0] reg26_D;
    logic [26:0] reg26_C;
    logic reg26_sign;
    logic [9:0] addr_reg26;
    logic enable_reg26;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg26_A <= 32'd0;
            reg26_B <= 32'd0;
            reg26_D <= 32'd0;
            reg26_C <= 27'd0;
            reg26_sign <= 1'd0;
            addr_reg26 <= 10'd0;
            enable_reg26 <= 1'd0;
        end else begin
            reg26_A <= reg25_A;
            reg26_B <= reg25_B;
            reg26_D <= pip25_D;
            reg26_C <= {reg25_C, pip25_C};
            reg26_sign <= reg25_sign;
            addr_reg26 <= addr_reg25;
            enable_reg26 <= enable_reg25;
        end
    end

    logic [31:0] pip26_D;
    logic pip26_C;
    divide_unit du26(
        .A({reg26_D[30:0], 1'b0}),
        .B(reg26_B),
        .D(pip26_D),
        .C(pip26_C)
    );
    //27-th pip
    logic [31:0] reg27_A;
    logic [31:0] reg27_B;
    logic [31:0] reg27_D;
    logic [27:0] reg27_C;
    logic reg27_sign;
    logic [9:0] addr_reg27;
    logic enable_reg27;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg27_A <= 32'd0;
            reg27_B <= 32'd0;
            reg27_D <= 32'd0;
            reg27_C <= 28'd0;
            reg27_sign <= 1'd0;
            addr_reg27 <= 10'd0;
            enable_reg27 <= 1'd0;
        end else begin
            reg27_A <= reg26_A;
            reg27_B <= reg26_B;
            reg27_D <= pip26_D;
            reg27_C <= {reg26_C, pip26_C};
            reg27_sign <= reg26_sign;
            addr_reg27 <= addr_reg26;
            enable_reg27 <= enable_reg26;
        end
    end

    logic [31:0] pip27_D;
    logic pip27_C;
    divide_unit du27(
        .A({reg27_D[30:0], 1'b0}),
        .B(reg27_B),
        .D(pip27_D),
        .C(pip27_C)
    );
    //28-th pip
    logic [31:0] reg28_A;
    logic [31:0] reg28_B;
    logic [31:0] reg28_D;
    logic [28:0] reg28_C;
    logic reg28_sign;
    logic [9:0] addr_reg28;
    logic enable_reg28;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg28_A <= 32'd0;
            reg28_B <= 32'd0;
            reg28_D <= 32'd0;
            reg28_C <= 29'd0;
            reg28_sign <= 1'd0;
            addr_reg28 <= 10'd0;
            enable_reg28 <= 1'd0;
        end else begin
            reg28_A <= reg27_A;
            reg28_B <= reg27_B;
            reg28_D <= pip27_D;
            reg28_C <= {reg27_C, pip27_C};
            reg28_sign <= reg27_sign;
            addr_reg28 <= addr_reg27;
            enable_reg28 <= enable_reg27;
        end
    end

    logic [31:0] pip28_D;
    logic pip28_C;
    divide_unit du28(
        .A({reg28_D[30:0], 1'b0}),
        .B(reg28_B),
        .D(pip28_D),
        .C(pip28_C)
    );
    //29-th pip
    logic [31:0] reg29_A;
    logic [31:0] reg29_B;
    logic [31:0] reg29_D;
    logic [29:0] reg29_C;
    logic reg29_sign;
    logic [9:0] addr_reg29;
    logic enable_reg29;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg29_A <= 32'd0;
            reg29_B <= 32'd0;
            reg29_D <= 32'd0;
            reg29_C <= 30'd0;
            reg29_sign <= 1'd0;
            addr_reg29 <= 10'd0;
            enable_reg29 <= 1'd0;
        end else begin
            reg29_A <= reg28_A;
            reg29_B <= reg28_B;
            reg29_D <= pip28_D;
            reg29_C <= {reg28_C, pip28_C};
            reg29_sign <= reg28_sign;
            addr_reg29 <= addr_reg28;
            enable_reg29 <= enable_reg28;
        end
    end

    logic [31:0] pip29_D;
    logic pip29_C;
    divide_unit du29(
        .A({reg29_D[30:0], 1'b0}),
        .B(reg29_B),
        .D(pip29_D),
        .C(pip29_C)
    );
    //30-th pip
    logic [31:0] reg30_A;
    logic [31:0] reg30_B;
    logic [31:0] reg30_D;
    logic [30:0] reg30_C;
    logic reg30_sign;
    logic [9:0] addr_reg30;
    logic enable_reg30;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg30_A <= 32'd0;
            reg30_B <= 32'd0;
            reg30_D <= 32'd0;
            reg30_C <= 31'd0;
            reg30_sign <= 1'd0;
            addr_reg30 <= 10'd0;
            enable_reg30 <= 1'd0;
        end else begin
            reg30_A <= reg29_A;
            reg30_B <= reg29_B;
            reg30_D <= pip29_D;
            reg30_C <= {reg29_C, pip29_C};
            reg30_sign <= reg29_sign;
            addr_reg30 <= addr_reg29;
            enable_reg30 <= enable_reg29;
        end
    end

    logic [31:0] pip30_D;
    logic pip30_C;
    divide_unit du30(
        .A({reg30_D[30:0], 1'b0}),
        .B(reg30_B),
        .D(pip30_D),
        .C(pip30_C)
    );
    //31-th pip
    logic [31:0] reg31_A;
    logic [31:0] reg31_B;
    logic [31:0] reg31_D;
    logic [31:0] reg31_C;
    logic reg31_sign;
    logic [9:0] addr_reg31;
    logic enable_reg31;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            reg31_A <= 32'd0;
            reg31_B <= 32'd0;
            reg31_D <= 32'd0;
            reg31_C <= 32'd0;
            reg31_sign <= 1'd0;
            addr_reg31 <= 10'd0;
            enable_reg31 <= 1'd0;
        end else begin
            reg31_A <= reg30_A;
            reg31_B <= reg30_B;
            reg31_D <= pip30_D;
            reg31_C <= {reg30_C, pip30_C};
            reg31_sign <= reg30_sign;
            addr_reg31 <= addr_reg30;
            enable_reg31 <= enable_reg30;
        end
    end

    logic [31:0] C_inv;
    assign C = (reg31_sign) ? ((reg31_C ^ 32'hffff_ffff) + 32'd1) : reg31_C;
    assign addr_out = addr_reg31;
    assign enable_out = enable_reg31;
endmodule