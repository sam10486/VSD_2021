`include "define.sv"

`include "ALU.sv"
`include "imm_gen.sv"
`include "ALU_control.sv"
`include "ADD_SUM.sv"
`include "Control.sv"
`include "Register_file.sv"
`include "Forwarding.sv"
`include "Hazard_detection.sv"
module CPU (
    input clk, rst,
    input [31:0] IM_data_out, DM_data_out,
    output logic [31:0] IM_addr, DM_addr,
    output logic [31:0] DM_data_in,
    output logic IM_CS, IM_OE, DM_CS, DM_OE,
    output logic [3:0] IM_WEB, DM_WEB
);

//-------------------variable-------------------
logic [4:0] WB_rd;
logic WB_RegWrite;
logic [1:0] FA, FB;
logic [31:0] Write_data;
logic [31:0] MEM_ALU_result, MEM_forward;
logic MEM_Jump, MEM_JALR, EX_Jump, EX_JALR, EX_Branch;
logic [31:0] EX_imm_add_rs1, EX_PC_add_4;
logic [31:0] EX_PCaddImm;
logic flush, flush_buf, flush_data, PCSrc;
logic stall;
logic PC_first;
//-----------flush setting----------------
assign flush = EX_Jump | EX_JALR | PCSrc;
always_ff @( posedge clk or posedge rst) begin : flush_buffer
    if (rst) begin
        flush_buf <= 1'd0;
    end else begin
        flush_buf <= flush;
    end 
end
assign flush_data = flush | flush_buf;
//---------------------------------------

//------------------ IF stage -----------------//
logic PC_vaild;
logic [31:0] PC, PC_in, PC_imm, PC_add_4, PC_in_jump_or_not;

always_ff @( posedge clk or posedge rst) begin
    if (rst) begin
        PC_first <= 1'd0;
    end else begin
        PC_first <= 1'd1;
    end
end

always_comb begin : branch_or_not
    if (PCSrc) begin
        PC_in = PC_imm;
    end else begin
        PC_in = PC_add_4;
    end
end
always_comb begin
    case({EX_Jump, EX_JALR})
        2'b00: PC_in_jump_or_not = PC_in;
        2'b01: PC_in_jump_or_not = EX_imm_add_rs1;
        2'b10: PC_in_jump_or_not = EX_PCaddImm;
        default: PC_in_jump_or_not = PC_in;
    endcase
end

always_ff @( posedge clk or posedge rst ) begin
    if (rst) begin
        PC_vaild <= 1'd0;
    end else begin
        PC_vaild <= 1'd1;
    end
end

always_ff @( posedge clk or posedge rst ) begin
    if (rst) begin
        PC <= 32'd0;
    end else if (~PC_vaild) begin
        PC <= 32'd0;
    end else if (stall) begin
        PC <= PC;
    end else begin
        PC <= PC_in_jump_or_not;
    end
end


ADD_SUM IF_add(
    .sel(1'd0),
    .PC(PC),
    .imm(32'd0),
    .PC_out(PC_add_4)
);

always_comb begin
    if (PC_vaild && ~stall) begin
        IM_addr = PC;
    end else if (stall) begin
        IM_addr = PC - 32'd4;
    end else begin
        IM_addr = 32'd0;
    end
    IM_WEB = 4'b1111;
    IM_CS = 1'b1;
    IM_OE = 1'b1;
end

logic [31:0] PC_add_4_delay, PC_delay;

always_ff @( posedge clk or posedge rst ) begin : blockName
    if (rst) begin
        PC_add_4_delay <= 32'd0;
        PC_delay <= 32'd0;
    end else if (stall) begin
        PC_add_4_delay <= PC_add_4_delay;
        PC_delay <= PC_delay;
    end else if (flush) begin
        PC_add_4_delay <= 32'd0;
        PC_delay <= 32'd0;
    end else begin
        PC_add_4_delay <= PC_add_4;
        PC_delay <= PC;
    end
end
logic [31:0] instruction;
assign instruction = IM_data_out;

//----------------------------------------

//------------------ IF/ID------------------

logic [31:0] ID_instruction;
logic [31:0] ID_PC;
logic [31:0] ID_PC_add4;

always_ff @( posedge clk or posedge rst ) begin : IF_ID
    if (rst) begin
        ID_PC <= 32'd0;
        ID_instruction <= 32'd0;
        ID_PC_add4 <= 32'd0;
	end else if(PC_first == 1'd0) begin
		ID_PC <= 32'd0;
        ID_instruction <= 32'd0;
        ID_PC_add4 <= 32'd0;
    end else if (stall) begin
        ID_PC <= ID_PC;
        ID_instruction <= ID_instruction;
        ID_PC_add4 <= ID_PC_add4;
    end else if (flush_data) begin
        ID_PC <= 32'd0;
        ID_instruction <= 32'd0;
        ID_PC_add4 <= 32'd0;
    end else begin
        ID_PC <= PC_delay;
        ID_instruction <= instruction;
        ID_PC_add4 <= PC_add_4_delay; 
    end
end
//--------------------------------------------

//-------------ID----------------------------
logic [4:0] ID_rs2, ID_rs1, ID_rd;
logic Reg_write;
logic [31:0] ID_imm;
logic [31:0] ID_Read_data1, ID_Read_data2;
logic [1:0] ID_MemtoReg;
logic ID_RegDst,ID_Branch, ID_MemRead, ID_MemWrite, ID_ALUSrc, 
      ID_RegWrite, ID_JALR, ID_PC_imm_ctr, ID_Jump, ID_Branch_inv,
      ID_LW, ID_LH, ID_LHU, ID_LBU, ID_LB, ID_SW, ID_SB, ID_SH;
logic [3:0] ID_ALUop;
assign ID_rd = ID_instruction[11:7];
assign ID_rs2 = ID_instruction[24:20];
assign ID_rs1 = ID_instruction[19:15];



Register_file Reg0(
    //input
    .Read_reg1(ID_rs1),
    .Read_reg2(ID_rs2),
    .Write_reg(WB_rd),
    .Write_data(Write_data),
    .Reg_write(WB_RegWrite),
    .clk(clk),
    .rst(rst),
    //output
    .Read_data1(ID_Read_data1),
    .Read_data2(ID_Read_data2)
);


imm_gen imm_gen(
    .instruction(ID_instruction),
    .imm(ID_imm)
);


Control control(
    .instruction(ID_instruction),
    .Branch(ID_Branch),
    .MemRead(ID_MemRead),
    .MemtoReg(ID_MemtoReg),
    .ALUop(ID_ALUop),
    .MemWrite(ID_MemWrite),
    .ALUSrc(ID_ALUSrc),
    .RegWrite(ID_RegWrite),
    .JALR(ID_JALR),
    .PC_imm_ctr(ID_PC_imm_ctr),
    .Jump(ID_Jump),
    .Branch_inv(ID_Branch_inv),
    .LW(ID_LW),
    .LH(ID_LH),
    .LHU(ID_LHU),
    .LBU(ID_LBU),
    .LB(ID_LB),
    .SW(ID_SW),
    .SB(ID_SB),
    .SH(ID_SH)
);


//----------------------------------

//----------ID/EX------------------
logic EX_MemRead;
logic [1:0] EX_MemtoReg;
logic [3:0] EX_ALUop;
logic EX_MemWrite;
logic EX_ALUSrc;
logic EX_RegWrite;
logic EX_PC_imm_ctr;
logic EX_Branch_inv;
logic EX_LW, EX_LH, EX_LHU, EX_LBU, EX_LB, EX_SW, EX_SB, EX_SH;
logic [4:0] EX_rs1, EX_rs2;
always_ff @( posedge clk or posedge rst ) begin : ID_EX_control
    if (rst) begin
        EX_Branch <= 1'd0;
        EX_MemRead <= 1'd0;
        EX_MemtoReg <= 2'b00;
        EX_ALUop <= 4'd0;
        EX_MemWrite <= 1'd0;
        EX_ALUSrc <= 1'd0;
        EX_RegWrite <= 1'd0;
        EX_JALR <= 1'd0;
        EX_PC_imm_ctr <= 1'd0;
        EX_Jump <= 1'd0;
        EX_Branch_inv <= 1'd0;
        EX_LW <= 1'd0;
        EX_LH <= 1'd0;
        EX_LHU <= 1'd0;
        EX_LBU <= 1'd0;
        EX_SW <= 1'd0;
        EX_SB <= 1'd0;
        EX_SH <= 1'd0;
        EX_LB <= 1'd0;
	end else if(stall) begin
		EX_Branch <= EX_Branch;
        EX_MemRead <= EX_MemRead;
        EX_MemtoReg <= EX_MemtoReg;
        EX_ALUop <= EX_ALUop;
        EX_MemWrite <= EX_MemWrite;
        EX_ALUSrc <= EX_ALUSrc;
        EX_RegWrite <= EX_RegWrite;
        EX_JALR <= EX_JALR;
        EX_PC_imm_ctr <= EX_PC_imm_ctr;
        EX_Jump <= EX_Jump;
        EX_Branch_inv <= EX_Branch_inv;
        EX_LW <= EX_LW;
        EX_LH <= EX_LH;
        EX_LHU <= EX_LHU;
        EX_LBU <= EX_LBU;
        EX_SW <= EX_SW;
        EX_SB <= EX_SB;
        EX_SH <= EX_SH;
        EX_LB <= EX_LB;
    end else if (flush_data) begin
        EX_Branch <= 1'd0;
        EX_MemRead <= 1'd0;
        EX_MemtoReg <= 2'b00;
        EX_ALUop <= 4'd0;
        EX_MemWrite <= 1'd0;
        EX_ALUSrc <= 1'd0;
        EX_RegWrite <= 1'd0;
        EX_JALR <= 1'd0;
        EX_PC_imm_ctr <= 1'd0;
        EX_Jump <= 1'd0;
        EX_Branch_inv <= 1'd0;
        EX_LW <= 1'd0;
        EX_LH <= 1'd0;
        EX_LHU <= 1'd0;
        EX_LBU <= 1'd0;
        EX_SW <= 1'd0;
        EX_SB <= 1'd0;
        EX_SH <= 1'd0;
        EX_LB <= 1'd0;
    end else begin
        EX_Branch <= ID_Branch;
        EX_MemRead <= ID_MemRead;
        EX_MemtoReg <= ID_MemtoReg;
        EX_ALUop <= ID_ALUop;
        EX_MemWrite <= ID_MemWrite;
        EX_ALUSrc <= ID_ALUSrc;
        EX_RegWrite <= ID_RegWrite;
        EX_JALR <= ID_JALR;
        EX_PC_imm_ctr <= ID_PC_imm_ctr;
        EX_Jump <= ID_Jump;
        EX_Branch_inv <= ID_Branch_inv;
        EX_LW <= ID_LW;
        EX_LH <= ID_LH;
        EX_LHU <= ID_LHU;
        EX_LBU <= ID_LBU;
        EX_SW <= ID_SW;
        EX_SB <= ID_SB;
        EX_SH <= ID_SH;
        EX_LB <= ID_LB;
    end
end

logic [31:0] EX_Read_data1, EX_Read_data2, EX_imm, EX_PC, EX_instruction;
logic [4:0] EX_rd;

always_ff @( posedge clk or posedge rst ) begin : ID_EX_data
    if (rst) begin
        EX_Read_data1 <= 32'd0;
        EX_Read_data2 <= 32'd0;
        EX_imm <= 32'd0;
        EX_instruction <= 32'd0;
        EX_PC <= 32'd0;
        EX_rd <= 5'd0;
        EX_rs1 <= 5'd0;
        EX_rs2 <= 5'd0;
        EX_PC_add_4 <= 32'd0;
	end else if (flush_data && !stall) begin
		EX_Read_data1 <= 32'd0;
		EX_Read_data2 <= 32'd0;
		EX_imm <= 32'd0;
		EX_instruction <= 32'd0;
		EX_PC <= 32'd0;
		EX_rd <= 5'd0;
		EX_rs1 <= 5'd0;
		EX_rs2 <= 5'd0;
		EX_PC_add_4 <= 32'd0;
	end else if(stall ) begin
		EX_Read_data1 <= EX_Read_data1;
        EX_Read_data2 <= EX_Read_data2;
        EX_imm <= EX_imm;
        EX_instruction <= EX_instruction;
        EX_PC <= EX_PC;
        EX_rd <= EX_rd;
        EX_rs1 <= EX_rs1;
        EX_rs2 <= EX_rs2;
        EX_PC_add_4 <= EX_PC_add_4;
    end else if (flush_data) begin
        EX_Read_data1 <= 32'd0;
        EX_Read_data2 <= 32'd0;
        EX_imm <= 32'd0;
        EX_instruction <= 32'd0;
        EX_PC <= 32'd0;
        EX_rd <= 5'd0;
        EX_rs1 <= 5'd0;
        EX_rs2 <= 5'd0;
        EX_PC_add_4 <= 32'd0;
    end else begin
        EX_Read_data1 <= ID_Read_data1;
        EX_Read_data2 <= ID_Read_data2;
        EX_imm <= ID_imm;
        EX_instruction <= ID_instruction;
        EX_PC <= ID_PC;
        EX_rd <= ID_rd;
        EX_rs1 <= ID_rs1;
        EX_rs2 <= ID_rs2;
        EX_PC_add_4 <= ID_PC_add4;
    end
end
//---------------------------------------------

//---------------EX---------------------------
logic [31:0] EX_ALU_result;
logic EX_ALU_zero;
logic [3:0] EX_ALU_control;
logic [31:0] EX_Read_data2_mux;
logic [31:0] EX_Read_data1_forward, EX_Read_data2_forward; 

ADD_SUM EX_ADD(
    //input
    .sel(1'd1),
    .PC(EX_PC),
    .imm(EX_imm),
    //output
    .PC_out(PC_imm)
);

ALU_control ALU_control(
    //input
    .ALUop(EX_ALUop),
    .instruction(EX_instruction),
    //output
    .ALU_control(EX_ALU_control)
);

always_comb begin 
    case(FA)
        2'b00: EX_Read_data1_forward = EX_Read_data1;
        2'b01: EX_Read_data1_forward = Write_data;
        2'b10: EX_Read_data1_forward = MEM_forward;
        default: EX_Read_data1_forward = EX_Read_data1;
    endcase    
    case(FB)
        2'b00: EX_Read_data2_forward = EX_Read_data2;
        2'b01: EX_Read_data2_forward = Write_data;
        2'b10: EX_Read_data2_forward = MEM_forward;
        default: EX_Read_data2_forward = EX_Read_data2;
    endcase
end

assign EX_Read_data2_mux = (EX_ALUSrc) ? (EX_imm) : EX_Read_data2_forward;

ALU EX_ALU(
    //output
    .ALU_result(EX_ALU_result),
    .ALU_zero(EX_ALU_zero),
    //input
    .ALU_rs1(EX_Read_data1_forward),
    .ALU_rs2(EX_Read_data2_mux),
    .ALU_control(EX_ALU_control)
);

assign EX_PCaddImm = PC_imm;
assign EX_imm_add_rs1 = EX_ALU_result;

logic condition_sel;
assign condition_sel =  (EX_Branch_inv) ? (!EX_ALU_zero) : EX_ALU_zero;
assign PCSrc = EX_Branch & condition_sel & ~stall; // branch or not  
//--------------------


//---------EX/MEM----------------
logic MEM_Branch;
logic MEM_MemRead;
logic [1:0] MEM_MemtoReg;
logic MEM_MemWrite;
logic MEM_RegWrite;
logic MEM_PC_imm_ctr;
//logic MEM_Branch_inv;
logic MEM_LW, MEM_LH, MEM_LHU, MEM_LBU, MEM_LB, MEM_SW, MEM_SB, MEM_SH;

always_ff @( posedge clk or posedge rst ) begin : EX_MEM_ctr
    if (rst) begin
        //MEM_Branch <= 1'd0;
        MEM_MemRead <= 1'd0;
        MEM_MemtoReg <= 2'b00;
        MEM_MemWrite <= 1'd0;
        MEM_RegWrite <= 1'd0;
        MEM_JALR <= 1'd0;
        MEM_PC_imm_ctr <= 1'd0;
        MEM_Jump <= 1'd0;
        //MEM_Branch_inv <= 1'd0;
        MEM_LW <= 1'd0;
        MEM_LH <= 1'd0;
        MEM_LHU <= 1'd0;
        MEM_LBU <= 1'd0;
        MEM_SW <= 1'd0;
        MEM_SB <= 1'd0;
        MEM_SH <= 1'd0;
        MEM_LB <= 1'd0;
	end else if(stall) begin
		MEM_MemRead <= MEM_MemRead;
        MEM_MemtoReg <= MEM_MemtoReg;
        MEM_MemWrite <= MEM_MemWrite;
        MEM_RegWrite <= MEM_RegWrite;
        MEM_JALR <= MEM_JALR;
        MEM_PC_imm_ctr <= MEM_PC_imm_ctr;
        MEM_Jump <= MEM_Jump;
        //MEM_Branch_inv <= EX_Branch_inv;
        MEM_LW <= MEM_LW;
        MEM_LH <= MEM_LH;
        MEM_LHU <= MEM_LHU;
        MEM_LBU <= MEM_LBU;
        MEM_SW <= MEM_SW;
        MEM_SB <= MEM_SB;
        MEM_SH <= MEM_SH;
        MEM_LB <= MEM_LB;
    end else begin
        //MEM_Branch <= EX_Branch;
        MEM_MemRead <= EX_MemRead;
        MEM_MemtoReg <= EX_MemtoReg;
        MEM_MemWrite <= EX_MemWrite;
        MEM_RegWrite <= EX_RegWrite;
        MEM_JALR <= EX_JALR;
        MEM_PC_imm_ctr <= EX_PC_imm_ctr;
        MEM_Jump <= EX_Jump;
        //MEM_Branch_inv <= EX_Branch_inv;
        MEM_LW <= EX_LW;
        MEM_LH <= EX_LH;
        MEM_LHU <= EX_LHU;
        MEM_LBU <= EX_LBU;
        MEM_SW <= EX_SW;
        MEM_SB <= EX_SB;
        MEM_SH <= EX_SH;
        MEM_LB <= EX_LB;
    end
end

//logic MEM_ALU_zero;
logic [31:0] MEM_Read_data2;
logic [31:0] MEM_PCaddImm, MEM_PC_add4, MEM_Read_data2_forward;
logic [31:0] MEM_imm;
logic [4:0] MEM_rd;

always_ff @( posedge clk or posedge rst ) begin : EX_MEM_data
    if (rst) begin
        //MEM_ALU_zero <= 1'd0;
        MEM_ALU_result <= 32'd0;
        MEM_Read_data2 <= 32'd0;
        MEM_imm <= 32'd0;
        MEM_PCaddImm <= 32'd0;
        MEM_rd <= 5'd0;
        MEM_PC_add4 <= 32'd0;
        MEM_Read_data2_forward <= 32'd0;
	end else if(stall) begin
		MEM_ALU_result <= MEM_ALU_result;
        MEM_Read_data2 <= MEM_Read_data2;
        MEM_imm <= MEM_imm;
        MEM_PCaddImm <= MEM_PCaddImm;
        MEM_rd <= MEM_rd;
        MEM_PC_add4 <= MEM_PC_add4;
        MEM_Read_data2_forward <= MEM_Read_data2_forward;
    end else begin
        //MEM_ALU_zero <= EX_ALU_zero;
        MEM_ALU_result <= EX_ALU_result;
        MEM_Read_data2 <= EX_Read_data2;
        MEM_imm <= EX_imm;
        MEM_PCaddImm <= EX_PCaddImm;
        MEM_rd <= EX_rd;
        MEM_PC_add4 <= EX_PC_add_4;
        MEM_Read_data2_forward <= EX_Read_data2_forward;
    end
end

//------------------------------------------

//----------MEM----------------------------
/*
logic condition_sel;
assign condition_sel =  (MEM_Branch_inv) ? (!MEM_ALU_zero) : MEM_ALU_zero;
assign PCSrc = MEM_Branch & condition_sel; // branch or not  */

logic [31:0] MEM_DM_data;
assign DM_CS = MEM_MemWrite | MEM_MemRead;
assign DM_OE = MEM_MemRead;
/*
always_comb begin : SRAM_Read_Write
    if (MEM_MemWrite || MEM_MemRead) begin
        DM_CS = 1'd1;
    end else begin
        DM_CS = 1'd0;
    end
    DM_CS = 1'd1;
    if (MEM_MemRead) begin
        DM_OE = 1'd1;
    end else begin
        DM_OE = 1'd0;
    end
end*/

always_comb begin
    if (DM_CS) begin
        DM_addr = MEM_ALU_result;
    end else begin
        DM_addr = 32'd0;
    end
end

always_comb begin : Store_process
    if (MEM_SB) begin
        case(MEM_ALU_result[1:0])
            2'b00: begin
                DM_WEB = 4'b1110;
                DM_data_in = {24'b0, MEM_Read_data2_forward[7:0]};
            end
            2'b01: begin
                DM_WEB = 4'b1101;
                DM_data_in = {16'd0, MEM_Read_data2_forward[7:0], 8'd0};
            end
            2'b10: begin
                DM_WEB = 4'b1011;
                DM_data_in = {8'd0, MEM_Read_data2_forward[7:0], 16'd0};
            end
            2'b11: begin
                DM_WEB = 4'b0111;
                DM_data_in = {MEM_Read_data2_forward[7:0], 24'd0};
            end
        endcase
    end else if (MEM_SH) begin
        case(MEM_ALU_result[1])
            1'b0: begin
                DM_WEB = 4'b1100;
                DM_data_in = {16'd0, MEM_Read_data2_forward[15:0]};
            end
            1'b1: begin
                DM_WEB = 4'b0011;
                DM_data_in = {MEM_Read_data2_forward[15:0], 16'd0};
            end
        endcase
    end else if (MEM_SW) begin
        DM_WEB = 4'b0000;
        DM_data_in = MEM_Read_data2_forward;
    end else begin
        DM_WEB = 4'b1111;
        DM_data_in = 32'd0;
    end
end


always_comb begin : Load_process
    if (MEM_LW) begin
        MEM_DM_data = DM_data_out;
    end else if (MEM_LH) begin
        MEM_DM_data = {{16{DM_data_out[15]}},DM_data_out[15:0]};
    end else if (MEM_LHU) begin
        MEM_DM_data = {16'd0,DM_data_out[15:0]};
    end else if (MEM_LBU) begin
        MEM_DM_data = {24'd0,DM_data_out[7:0]};
    end else if (MEM_LB) begin
        MEM_DM_data = {{24{DM_data_out[15]}},DM_data_out[7:0]};
    end else begin
        MEM_DM_data = 32'd0;
    end
end

logic [31:0] MEM_PCaddImm_or_imm;
assign MEM_PCaddImm_or_imm = (MEM_PC_imm_ctr) ?  MEM_PCaddImm : MEM_imm;

always_comb begin
    case(MEM_MemtoReg)
        2'b00: MEM_forward = MEM_ALU_result;
		2'b01: MEM_forward = MEM_DM_data;
        2'b10: MEM_forward = MEM_PC_add4;
        2'b11: MEM_forward = MEM_PCaddImm_or_imm;
        //default: MEM_forward = MEM_ALU_result;
    endcase
end
//--------------------------------------------------

//-----------MEM/WB------------------
logic [1:0] WB_MemtoReg;

always_ff @( posedge clk or posedge rst ) begin : MEM_WB
    if (rst) begin
        WB_MemtoReg <= 2'd0;
        WB_RegWrite <= 1'd0;  
	end else if(stall) begin
		WB_MemtoReg <= WB_MemtoReg;
        WB_RegWrite <= WB_RegWrite; 
    end else begin
        WB_MemtoReg <= MEM_MemtoReg;
        WB_RegWrite <= MEM_RegWrite;  
    end
end

logic [31:0] WB_ALU_result, WB_DM_data, WB_PC_add4, WB_PCaddImm_or_imm;

always_ff @( posedge clk or posedge rst ) begin
    if (rst) begin
        WB_ALU_result <= 32'd0;
        WB_DM_data <= 32'd0;
        WB_rd <= 5'd0;
        WB_PC_add4 <= 32'd0;
        WB_PCaddImm_or_imm <= 32'd0;
	end else if(stall) begin
		WB_ALU_result <= WB_ALU_result;
        WB_DM_data <= WB_DM_data;
        WB_rd <= WB_rd;
        WB_PC_add4 <= WB_PC_add4;
        WB_PCaddImm_or_imm <= WB_PCaddImm_or_imm;
    end else begin
        WB_ALU_result <= MEM_ALU_result;
        WB_DM_data <= MEM_DM_data;
        WB_rd <= MEM_rd;
        WB_PC_add4 <= MEM_PC_add4;
        WB_PCaddImm_or_imm <= MEM_PCaddImm_or_imm;
    end
end
//---------------------------------------

//-------------WB stage-------------

always_comb begin
    case(WB_MemtoReg)
        2'b00: begin
            Write_data = WB_ALU_result;
        end
        2'b01: begin
            Write_data = WB_DM_data;
        end
        2'b10: begin
            Write_data = WB_PC_add4;
        end
        2'b11: begin
            Write_data = WB_PCaddImm_or_imm;
        end
    endcase
end

//---------------forwarding block------------

Forwarding Forwarding(
    //output
    .FA(FA),
    .FB(FB),
    //input
    .EX_rs1(EX_rs1),
    .EX_rs2(EX_rs2),
    .MEM_rd(MEM_rd),
    .WB_rd(WB_rd),
    .WB_RegWrite(WB_RegWrite),
    .MEM_RegWrite(MEM_RegWrite)
);

//----------------------------------

//----------------Hazard detection--------------------
Hazard_detection hazard_detection(
    //input
    .EX_MemRead(EX_MemRead),
    .MEM_MemRead(MEM_MemRead),
    .ID_rs1(ID_rs1),
    .ID_rs2(ID_rs2),
    .EX_rd(EX_rd),
    .MEM_rd(MEM_rd),
	.clk(clk),
	.rst(rst),
    //output
    .stall(stall)
);
//--------------------------------------------------


endmodule
