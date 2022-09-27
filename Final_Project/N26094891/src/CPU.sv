///`include "ALU_controller.sv"
`include "ALU.sv"
`include "ALU_small.sv"
`include "define.sv"
`include "MUX2x1.sv"
`include "MUX4x1.sv"
`include "reg32x32.sv"
`include "PC_add_4.sv"
`include "ImmGen.sv"
`include "main_controller.sv"
`include "LW_MUX.sv"
`include "SW_MUX.sv"
`include "SW_controller.sv"
`include "forward.sv"
`include "hazard.sv"
`include "CSR.sv"


`define Idle      3'b000
`define ReadAddr  3'b001
`define ReadData  3'b010
`define WriteAddr 3'b011
`define WriteData 3'b100
`define WriteResp 3'b101
`define Wait	  3'b110



module CPU(
input clk, rst,
input [31:0] IM_output, DM_output,
output logic [31:0] DM_input,
output logic [31:0] IM_addr,
output logic [31:0] DM_addr,
output logic IM_CS, IM_OE, DM_CS, DM_OE,
output logic [3:0] IM_WEB, DM_WEB,
input CPU_Ready,
input [2:0] cs_m0, ns_m0, cs_m1, ns_m1,
output logic [2:0] EXMEM_Cache_type,
input interrupt);

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////reg and wire/////////////////////////////////////////
//----IF----//
logic [31:0] PC;
logic [31:0] PC_MUX_out;
logic [31:0] PCadd4;
logic [31:0] PC_csr;//CSR
//----IF/ID----//
//reg
logic [31:0] IFID_instruction;
logic [31:0] IFID_PC;

//----ID----//
//wire
logic [31:0] imm;
logic RegWrite, MemWrite, MemRead, Branch, MemtoReg, Jump;
logic [1:0] ALUSrc1, ALUSrc2;
logic ALUSrc3; 
logic [4:0] ALUOp;
logic [4:0] rs1_addr, rs2_addr, rd_addr;
logic [31:0] read_data1, read_data2;
logic [2:0] funct3;

//----ID/EX----//
//reg
logic [31:0] IDEX_imm;
logic [31:0] IDEX_PC;
logic [31:0] IDEX_read_data1;
logic [31:0] IDEX_read_data2;
logic [4:0] IDEX_rd_addr;
logic IDEX_RegWrite, IDEX_MemWrite, IDEX_MemRead, IDEX_Branch, IDEX_MemtoReg, IDEX_Jump;
logic [1:0] IDEX_ALUSrc1, IDEX_ALUSrc2;
logic IDEX_ALUSrc3;
logic [4:0] IDEX_ALUOp;
logic [2:0] IDEX_funct3;

//----EX----//
//wire
logic [31:0] ALU_small_result, ALU_result;
logic ALU_zero;
logic [31:0] ALUSrc_MUX1_out, ALUSrc_MUX2_out, ALUSrc_MUX3_out;
logic EX_Jump;

//----EX/MEM----//
//reg
logic [31:0] EXMEM_ALU_small_result, EXMEM_ALU_result, EXMEM_read_data2;
logic EXMEM_ALU_zero;
logic [4:0] EXMEM_rd_addr;
logic [2:0] EXMEM_funct3;
logic EXMEM_RegWrite, EXMEM_MemWrite, EXMEM_MemRead, EXMEM_Branch, EXMEM_MemtoReg;

//----MEM----//
///wire
logic PCSrc;
logic [31:0] LW_out;

//----MEM/WB----//
//reg
logic [31:0] MEMWB_DM_read_data, MEMWB_ALU_result;
logic [4:0] MEMWB_rd_addr;
logic MEMWB_RegWrite, MEMWB_MemtoReg;

//----WB----//
logic [31:0] write_back_data;

//----stall----//
logic stall1;
logic stall1_D1;
logic stall_in;


//----CSR----//
logic wait_for_interrupt;
logic interrupt_taken;
logic interrupt_return;
logic [31:0] IDEX_instruction;
logic interrupt_return_;
logic interrupt_taken_;
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////








//------------------------------IF------------------------------//
///assign IM_addr = PC[14:0];
logic [31:0] PC_;
logic [31:0] PC_2;
logic [31:0] PC_3;
logic PCSrc_, PCSrc2, PCSrc3, PCSrc__;
logic [31:0] PC_MUX_out_;
//assign IM_addr = (~EXMEM_MemRead) ? PC : (PC - 32'd4);///PC
//assign IM_addr = (~CPU_Ready)?PC_:PC;///PC
always@(*)begin
	if(wait_for_interrupt)begin//CSR
		IM_addr = PC_;
	end
	else if(stall_in)begin
		IM_addr = PC_;
	end
	else if(PCSrc && CPU_Ready)begin
		IM_addr = 32'd0;
	end
	else if(PCSrc)begin
		IM_addr = PC_;
	end
	
	else if(~CPU_Ready)begin
		IM_addr = PC_;
	end
	else begin
		IM_addr = PC;
	end
end
//assign IM_addr = PC_;///PC
//assign IM_addr = PC;///PC

assign EXMEM_Cache_type = EXMEM_funct3;


PC_add_4 PC_add_4_1(.PC(PC),///PC 
					.PCadd4(PCadd4));

MUX2x1 MUX2x1_2(.mux_input1(PCadd4), 
				.mux_input2(ALU_small_result), 
				.sel(PCSrc), 
				.mux_output(PC_MUX_out_));//CSR(.mux_output(PC_MUX_out))
				
assign PC_MUX_out = (interrupt_return | interrupt_taken) ? PC_csr : PC_MUX_out_;

assign IM_OE = 1'b1;
assign IM_WEB = 4'b1111;
assign IM_CS = IM_WEB[0] | IM_WEB[1] | IM_WEB[2] | IM_WEB[3] | IM_OE;


always@(posedge clk, posedge rst)begin
	if(rst)begin
		PC <= 32'd0;
	end
	else if(~CPU_Ready) begin
		PC <= PC;
	end
	else if(interrupt_return)begin///CSR
		PC <= PC_csr;
	end
	else if(interrupt_taken)begin///CSR
		PC <= PC_csr;
	end
	else if(wait_for_interrupt)begin///CSR2022
		PC <= PC;
	end
	else if(stall_in) begin
		PC <= PC;
	end
	else begin
		PC <= PC_MUX_out;
	end
end


always@(posedge clk, posedge rst)begin
	if(rst)begin
		PC_ <= 32'd0;
	end
	else if(~CPU_Ready)begin
		PC_ <= PC_;
	end
	else if(interrupt_return | interrupt_taken)begin//CSR flush
		PC_ <= 32'd0;///???????
	end
	else if(wait_for_interrupt)begin//CSR stall
		PC_ <= PC_;///???????
	end
	else if(PCSrc)begin
		PC_ <= 32'd0;///???????
	end
	else if(stall_in)begin
		PC_ <= PC_;
	end
	else begin
		PC_ <= PC;
	end
end

///
logic interrput_flush_;
always@(posedge clk, posedge rst)begin
	if(rst)begin
		interrput_flush_ <= 1'b0;
	end
	else if(~CPU_Ready || wait_for_interrupt)begin///2022
		interrput_flush_ <= interrput_flush_;
	end
	else begin
		interrput_flush_ <= interrupt_return | interrupt_taken;
	end
end

logic interrput_flush_2;
always@(posedge clk, posedge rst)begin
	if(rst)begin
		interrput_flush_2 <= 1'b0;
	end
	else if(~CPU_Ready || wait_for_interrupt)begin///2022
		interrput_flush_2 <= interrput_flush_2;
	end
	else begin
		interrput_flush_2 <= interrput_flush_;
	end
end

//------------------------------IF/ID------------------------------//
always@(posedge clk, posedge rst)begin
	if(rst)begin
		IFID_instruction <= 32'd0;
		IFID_PC <= 32'd0;
	end
	else if(~CPU_Ready) begin
		IFID_instruction <= IFID_instruction;
		IFID_PC <= IFID_PC;
	end
	else if(interrupt_return | interrupt_taken)begin///interrupt flush
		IFID_instruction <= 32'd0;
		IFID_PC <= 32'd0;
	end
	else if(wait_for_interrupt)begin///interrupt stall
		IFID_instruction <= IFID_instruction;
		IFID_PC <= IFID_PC;
	end
	else if(PCSrc)begin///flush
		IFID_instruction <= 32'd0;
		IFID_PC <= 32'd0;
	end
	else if(stall_in) begin
		IFID_instruction <= IFID_instruction;
		IFID_PC <= IFID_PC;
	end
	else begin
		IFID_instruction <= (PCSrc_ | interrput_flush_) ? 32'd0 : IM_output;////????
		IFID_PC <= PC_;			//PC
	end
	
end

//------------------------------ID------------------------------//
assign rs1_addr = IFID_instruction[19:15];
assign rs2_addr = IFID_instruction[24:20];
assign rd_addr = IFID_instruction[11:7];
assign funct3 = IFID_instruction[14:12];

ImmGen ImmGen_1(.instruction(IFID_instruction), 
					.imm(imm));

main_controller main_controller_1(.instruction(IFID_instruction), 
								  .RegWrite(RegWrite), 
								  .MemWrite(MemWrite),
								  .MemRead(MemRead), 
								  .ALUSrc1(ALUSrc1), 
								  .ALUSrc2(ALUSrc2), 
								  .ALUSrc3(ALUSrc3),  
								  .Branch(Branch), 
								  .ALUOp(ALUOp), 
								  .MemtoReg(MemtoReg),
								  .Jump(Jump));

reg32x32 reg32x32_1(.read_addr1(rs1_addr),
					.read_addr2(rs2_addr), 
					.write_addr(MEMWB_rd_addr),
					.write_data(write_back_data),
					.read_data1(read_data1), 
					.read_data2(read_data2), 
					.clk(clk), 
					.rst(rst), 
					.reg_write(MEMWB_RegWrite));

hazard hazard_1(.IDEX_MemRead(IDEX_MemRead),//IDEX_MemReadEXMEM_MemRead
				.IDEX_rd_addr(IDEX_rd_addr),//IDEX_rd_addrEXMEM_rd_addr
				.IFID_rs1_addr(rs1_addr),
				.IFID_rs2_addr(rs2_addr),
				.stall1(stall1));

/*			
always@(posedge clk, posedge rst)begin//stall delay a clock
	if(rst)begin
		stall1_D1 <= 1'b0;
	end
	else if(~CPU_Ready)begin
		stall1_D1 <= stall1_D1;
	end
	else begin
		stall1_D1 <= stall1;
	end
end

assign stall_in = stall1_D1 | stall1;//stall for 2 clocks
*/


assign stall_in = stall1;//stall for 1 clock


//#####################################################//
//CSR
logic [31:0] csr_in;

logic [31:0] csr_out;
logic [31:0] IDEX_csr_out;
logic [31:0] EXMEM_csr_out;
logic [31:0] MEMWB_csr_out;

logic [11:0] csr_read_addr;
logic [11:0] IDEX_csr_read_addr;
logic [11:0] EXMEM_csr_read_addr;

logic [31:0] csr_out_forwarding;

logic csr_write;
logic IDEX_csr_write;
logic EXMEM_csr_write;
logic MEMWB_csr_write;


assign wait_for_interrupt = (IDEX_instruction == 32'b0001000_00101_00000_000_00000_1110011)? 1'd1: 1'd0;

always@(*)begin
	if(IDEX_instruction[6:0] == 7'b1100111)begin///JALR
		interrupt_return = 1'd0;
	end
	else begin
		if(IFID_instruction == 32'b0011000_00010_00000_000_00000_1110011)begin
			interrupt_return = 1'd1;
		end
		else begin
			interrupt_return = 1'd0;
		end
	end
end


assign csr_read_addr = IFID_instruction[31:20];
assign csr_write = (IFID_instruction[6:0] == 7'b1110011) ? 1'b1: 1'b0;

logic [11:0] csr_write_addr;
assign csr_write_addr = IDEX_instruction[31:20];



logic [31:0] PC_interrput;
assign PC_interrput = (PCSrc3) ? PC_ : PC_ - 32'd4;
CSR CSR(
.clk(clk),
.rst(rst),

.csr_write(IDEX_csr_write),
.csr_write_addr(csr_write_addr),
.csr_write_data(csr_in),

.csr_read_addr(csr_read_addr),

.interrupt_taken(interrupt_taken),
.interrupt_return(interrupt_return),
.interrupt(interrupt),
.pc(PC_interrput),//IFID_PC 2022

//jjhu
.wait_for_interrupt(wait_for_interrupt),

.csr_pc(PC_csr),
.csr_read_data(csr_out),

.CPU_ready(CPU_Ready)
);


always@(posedge clk, posedge rst)begin
	if(rst)begin
		interrupt_return_ <= 1'd0;
		interrupt_taken_  <= 1'd0;
	end
	else if(~CPU_Ready) begin
		interrupt_return_ <= interrupt_return_;
		interrupt_taken_ <= interrupt_taken_;
	end
	else begin
		interrupt_return_ <= interrupt_return;
		interrupt_taken_ <= interrupt_taken;
	end
	
end




///CSR ALU
always@(*)begin
	case(IDEX_funct3)
		3'b001:csr_in = ALUSrc_MUX2_out;
		3'b010:csr_in = ALUSrc_MUX2_out | csr_out_forwarding;
		3'b011:csr_in = (~ALUSrc_MUX2_out) & csr_out_forwarding;
		3'b101:csr_in = {27'd0, IDEX_instruction[19:15]};
		3'b110:csr_in = {27'd0, IDEX_instruction[19:15]} | csr_out_forwarding;
		3'b111:csr_in = (~{27'd0, IDEX_instruction[19:15]}) & csr_out_forwarding;
		default:csr_in = 32'd0;
	endcase
end

///CSR forwarding
logic csr_forwarding1;
logic csr_forwarding2;



/*
always@(*)begin
	if((EXMEM_csr_write == 1'd1) && (IDEX_csr_read_addr == EXMEM_rd_addr))begin
		csr_out_forwarding = EXMEM_csr_out;
		csr_forwarding1 = 1'b1;
		csr_forwarding2 = 1'b0;
	end
	else begin
		csr_out_forwarding = IDEX_csr_out;
		csr_forwarding1 = 1'b0;
		csr_forwarding2 = 1'b1;
	end
end
*/

always@(*)begin
	//if((IDEX_csr_write == 1'd1) && (csr_write_addr == csr_read_addr))begin
		//csr_out_forwarding = IDEX_csr_out;
		//csr_forwarding1 = 1'b1;
		//csr_forwarding2 = 1'b0;
	//end
	//else begin
		csr_out_forwarding = IDEX_csr_out;
		csr_forwarding1 = 1'b0;
		csr_forwarding2 = 1'b1;
	//end
end




//#####################################################//

					
//------------------------------ID/EX------------------------------//
logic [4:0] IDEX_rs1_addr, IDEX_rs2_addr;

always@(posedge clk, posedge rst)begin
	if(rst)begin
		IDEX_RegWrite <= 1'd0;
		IDEX_MemWrite <= 1'd0;
		IDEX_MemRead <= 1'd0;
		IDEX_ALUSrc1 <= 2'd0;
		IDEX_ALUSrc2 <= 2'd0;
		IDEX_ALUSrc3 <= 1'd0;
		IDEX_Branch <= 1'd0;
		IDEX_MemtoReg <= 1'd0;
		IDEX_Jump <= 1'd0;
		IDEX_ALUOp <= 5'd0;
		IDEX_imm <= 32'd0;
		IDEX_PC <= 32'd0;
		IDEX_read_data1 <= 32'd0;
		IDEX_read_data2 <= 32'd0;
		IDEX_rd_addr <= 5'd0;
		IDEX_funct3 <= 3'd0;
		///forwarding
		IDEX_rs1_addr <= 5'd0;
		IDEX_rs2_addr <= 5'd0;
		///CSR
		IDEX_instruction <= 32'd0;
		IDEX_csr_out <= 32'd0;
		IDEX_csr_write <= 1'd0;
		IDEX_csr_read_addr <= 12'd0;
	end
	else if(~CPU_Ready)begin
		IDEX_RegWrite <= IDEX_RegWrite;
		IDEX_MemWrite <= IDEX_MemWrite;
		IDEX_MemRead <= IDEX_MemRead;
		IDEX_ALUSrc1 <= IDEX_ALUSrc1;
		IDEX_ALUSrc2 <= IDEX_ALUSrc2;
		IDEX_ALUSrc3 <= IDEX_ALUSrc3;
		IDEX_Branch <= IDEX_Branch;
		IDEX_MemtoReg <= IDEX_MemtoReg;
		IDEX_Jump <= IDEX_Jump;
		IDEX_ALUOp <= IDEX_ALUOp;
		IDEX_imm <= IDEX_imm;
		IDEX_PC <= IDEX_PC;
		IDEX_read_data1 <= IDEX_read_data1;
		IDEX_read_data2 <= IDEX_read_data2;
		IDEX_rd_addr <= IDEX_rd_addr;
		IDEX_funct3 <= IDEX_funct3;
		///forwarding
		IDEX_rs1_addr <= IDEX_rs1_addr;
		IDEX_rs2_addr <= IDEX_rs2_addr;	
		///CSR
		IDEX_instruction <= IDEX_instruction;
		IDEX_csr_out <= IDEX_csr_out;
		IDEX_csr_write <= IDEX_csr_write;
		IDEX_csr_read_addr <= IDEX_csr_read_addr;
	end
	else if(interrupt_return | interrupt_taken)begin//interrupt flush
		IDEX_RegWrite <= 1'd0;
		IDEX_MemWrite <= 1'd0;
		IDEX_MemRead <= 1'd0;
		IDEX_ALUSrc1 <= 2'd0;
		IDEX_ALUSrc2 <= 2'd0;
		IDEX_ALUSrc3 <= 1'd0;
		IDEX_Branch <= 1'd0;
		IDEX_MemtoReg <= 1'd0;
		IDEX_Jump <= 1'd0;
		IDEX_ALUOp <= 5'd0;
		IDEX_imm <= 32'd0;
		IDEX_PC <= 32'd0;
		IDEX_read_data1 <= 32'd0;
		IDEX_read_data2 <= 32'd0;
		IDEX_rd_addr <= 5'd0;
		IDEX_funct3 <= 3'd0;
		///forwarding
		IDEX_rs1_addr <= 5'd0;
		IDEX_rs2_addr <= 5'd0;	
		///CSR
		IDEX_instruction <= 32'd0;
		IDEX_csr_out <= 32'd0;
		IDEX_csr_write <= 1'd0;
		IDEX_csr_read_addr <= 12'd0;
	end
	else if(wait_for_interrupt)begin//interrupt stall
		IDEX_RegWrite <= IDEX_RegWrite;
		IDEX_MemWrite <= IDEX_MemWrite;
		IDEX_MemRead <= IDEX_MemRead;
		IDEX_ALUSrc1 <= IDEX_ALUSrc1;
		IDEX_ALUSrc2 <= IDEX_ALUSrc2;
		IDEX_ALUSrc3 <= IDEX_ALUSrc3;
		IDEX_Branch <= IDEX_Branch;
		IDEX_MemtoReg <= IDEX_MemtoReg;
		IDEX_Jump <= IDEX_Jump;
		IDEX_ALUOp <= IDEX_ALUOp;
		IDEX_imm <= IDEX_imm;
		IDEX_PC <= IDEX_PC;
		IDEX_read_data1 <= IDEX_read_data1;
		IDEX_read_data2 <= IDEX_read_data2;
		IDEX_rd_addr <= IDEX_rd_addr;
		IDEX_funct3 <= IDEX_funct3;
		///forwarding
		IDEX_rs1_addr <= IDEX_rs1_addr;
		IDEX_rs2_addr <= IDEX_rs2_addr;	
		///CSR
		IDEX_instruction <= IDEX_instruction;
		IDEX_csr_out <= IDEX_csr_out;
		IDEX_csr_write <= IDEX_csr_write;
		IDEX_csr_read_addr <= IDEX_csr_read_addr;
	end
	else if(PCSrc | stall_in)begin
		IDEX_RegWrite <= 1'd0;
		IDEX_MemWrite <= 1'd0;
		IDEX_MemRead <= 1'd0;
		IDEX_ALUSrc1 <= 2'd0;
		IDEX_ALUSrc2 <= 2'd0;
		IDEX_ALUSrc3 <= 1'd0;
		IDEX_Branch <= 1'd0;
		IDEX_MemtoReg <= 1'd0;
		IDEX_Jump <= 1'd0;
		IDEX_ALUOp <= 5'd0;
		IDEX_imm <= 32'd0;
		IDEX_PC <= 32'd0;
		IDEX_read_data1 <= 32'd0;
		IDEX_read_data2 <= 32'd0;
		IDEX_rd_addr <= 5'd0;
		IDEX_funct3 <= 3'd0;
		///forwarding
		IDEX_rs1_addr <= 5'd0;
		IDEX_rs2_addr <= 5'd0;	
		///CSR
		IDEX_instruction <= 32'd0;
		IDEX_csr_out <= 32'd0;
		IDEX_csr_write <= 1'd0;
		IDEX_csr_read_addr <= 12'd0;
	end
	else begin
		IDEX_RegWrite <= RegWrite;
		IDEX_MemWrite <= MemWrite;
		IDEX_MemRead <= MemRead;
		IDEX_ALUSrc1 <= ALUSrc1;
		IDEX_ALUSrc2 <= ALUSrc2;
		IDEX_ALUSrc3 <= ALUSrc3;
		IDEX_Branch <= Branch;
		IDEX_MemtoReg <= MemtoReg;
		IDEX_Jump <= Jump;
		IDEX_ALUOp <= ALUOp;
		IDEX_imm <= imm;
		IDEX_PC <= IFID_PC;
		IDEX_read_data1 <= read_data1;
		IDEX_read_data2 <= read_data2;
		IDEX_rd_addr <= rd_addr;
		IDEX_funct3 <= funct3;
		///forwarding
		IDEX_rs1_addr <= rs1_addr;
		IDEX_rs2_addr <= rs2_addr;
		///CSR
		IDEX_instruction <= IFID_instruction;
		IDEX_csr_out <= csr_out;
		IDEX_csr_write <= csr_write;
		IDEX_csr_read_addr <= csr_read_addr;
	end
	
end

//------------------------------EX------------------------------//

///forwarding uint
logic [1:0] forwardSrc1, forwardSrc2;
logic [31:0] forward_MUX_out1, forward_MUX_out2;

forward	forward_1(.EXMEM_RegWrite(EXMEM_RegWrite),
					.EXMEM_rd_addr(EXMEM_rd_addr),
					.IDEX_rs1_addr(IDEX_rs1_addr),
					.IDEX_rs2_addr(IDEX_rs2_addr),
					.MEMWB_RegWrite(MEMWB_RegWrite),
					.MEMWB_rd_addr(MEMWB_rd_addr),
					.forwardSrc1(forwardSrc1),
					.forwardSrc2(forwardSrc2));

MUX4x1 MUX4x1_forward1(.mux_input1(IDEX_read_data2), 
						.mux_input2(EXMEM_ALU_result), 
						.mux_input3(write_back_data),
						.mux_input4(32'd0),
						.sel(forwardSrc2),
						.mux_output(forward_MUX_out1));
						
MUX4x1 MUX4x1_forward2(.mux_input1(IDEX_read_data1), 
						.mux_input2(EXMEM_ALU_result), 
						.mux_input3(write_back_data),
						.mux_input4(32'd0),
						.sel(forwardSrc1),
						.mux_output(forward_MUX_out2));

logic [31:0] EXMEM_PC;
logic [31:0] MEMWB_PC;

MUX4x1 MUX4x1_1(.mux_input1(forward_MUX_out1), 
				.mux_input2(IDEX_imm), 
				.mux_input3(32'd4), 
				.mux_input4(32'd0), 
				.sel(IDEX_ALUSrc1), 
				.mux_output(ALUSrc_MUX1_out));///Src1


MUX4x1 MUX4x1_2(.mux_input1(forward_MUX_out2), 
				.mux_input2(IDEX_PC), 
				.mux_input3(32'd0), 
				.mux_input4(32'd0), 
				.sel(IDEX_ALUSrc2), 
				.mux_output(ALUSrc_MUX2_out));///Src2


MUX2x1 MUX2x1_1(.mux_input1(IDEX_PC), //////////?
				.mux_input2(forward_MUX_out2), 
				.sel(IDEX_ALUSrc3), 
				.mux_output(ALUSrc_MUX3_out));///Src3


ALU_small ALU_small_1(.alu_input1(ALUSrc_MUX3_out), 
					  .alu_input2(IDEX_imm), 
					  .alu_output(ALU_small_result));


ALU ALU_1(.alu_input1(ALUSrc_MUX2_out), 
		  .alu_input2(ALUSrc_MUX1_out), 
		  .alu_op(IDEX_ALUOp), 
		  .funct3(IDEX_funct3), 
		  .alu_output(ALU_result), 
		  .alu_zero_output(ALU_zero));
			
///assign EX_Jump = IDEX_Jump ? 1'b1 : ALU_zero;
assign EX_Jump = IDEX_Jump | ALU_zero;

//------------------------------EX/MEM------------------------------//
logic [31:0] EXMEM_ALU_result_;///CSR
always@(posedge clk, posedge rst)begin
	if(rst)begin
		EXMEM_ALU_small_result <= 32'd0;
		EXMEM_ALU_result_ <= 32'd0;///CSR
		EXMEM_read_data2 <= 32'd0;
		EXMEM_ALU_zero <= 1'd0;
		EXMEM_rd_addr <= 5'd0;
		EXMEM_RegWrite <= 1'd0;
		EXMEM_MemWrite <= 1'd0;
		EXMEM_MemRead <= 1'd0;
		EXMEM_Branch <= 1'd0;
		EXMEM_MemtoReg <= 1'd0;
		EXMEM_funct3 <= 3'd0;
		EXMEM_PC <= 32'd0;
		//CSR
		EXMEM_csr_out <= 32'd0;
		EXMEM_csr_write <= 1'd0;
		EXMEM_csr_read_addr <= 12'd0;
	end
	else if(~CPU_Ready)begin
		EXMEM_ALU_small_result <= EXMEM_ALU_small_result;
		EXMEM_ALU_result_ <= EXMEM_ALU_result_;///CSR
		EXMEM_read_data2 <= EXMEM_read_data2;
		EXMEM_ALU_zero <= EXMEM_ALU_zero;
		EXMEM_rd_addr <= EXMEM_rd_addr;
		EXMEM_RegWrite <= EXMEM_RegWrite;
		
		
		if(cs_m1 == `WriteResp)begin
			EXMEM_MemWrite <= 1'b0;
		end
		else begin
			EXMEM_MemWrite <= EXMEM_MemWrite;
		end
		
		if((cs_m1 == `ReadData) && (ns_m1 == `Idle))begin
			EXMEM_MemRead <= 1'b0;
		end
		else begin
			EXMEM_MemRead <= EXMEM_MemRead;
		end
		
		
		//EXMEM_MemWrite <= EXMEM_MemWrite;
		//EXMEM_MemRead <= EXMEM_MemRead;
		
		
		
		EXMEM_Branch <= EXMEM_Branch;
		EXMEM_MemtoReg <= EXMEM_MemtoReg;
		EXMEM_funct3 <= EXMEM_funct3;
		EXMEM_PC <= EXMEM_PC;
		//CSR
		EXMEM_csr_out <= EXMEM_csr_out;
		EXMEM_csr_write <= EXMEM_csr_write;
		EXMEM_csr_read_addr <= EXMEM_csr_read_addr;
	end
	/*
	else if(stall_in)begin
		EXMEM_ALU_small_result <= EXMEM_ALU_small_result;
		EXMEM_ALU_result <= EXMEM_ALU_result;
		EXMEM_read_data2 <= EXMEM_read_data2;
		EXMEM_ALU_zero <= EXMEM_ALU_zero;
		EXMEM_rd_addr <= EXMEM_rd_addr;
		EXMEM_RegWrite <= EXMEM_RegWrite;
		EXMEM_MemWrite <= EXMEM_MemWrite;
		EXMEM_MemRead <= EXMEM_MemRead;
		EXMEM_Branch <= EXMEM_Branch;
		EXMEM_MemtoReg <= EXMEM_MemtoReg;
		EXMEM_funct3 <= EXMEM_funct3;
		EXMEM_PC <= EXMEM_PC;
	end
	*/
	else begin
		EXMEM_ALU_small_result <= ALU_small_result;
		EXMEM_ALU_result_ <= ALU_result;///CSR
		EXMEM_read_data2 <= forward_MUX_out1;
		EXMEM_ALU_zero <= EX_Jump;
		EXMEM_rd_addr <= IDEX_rd_addr;
		EXMEM_RegWrite <= IDEX_RegWrite;
		EXMEM_MemWrite <= IDEX_MemWrite;
		EXMEM_MemRead <= IDEX_MemRead;
		EXMEM_Branch <= IDEX_Branch;
		EXMEM_MemtoReg <= IDEX_MemtoReg;
		EXMEM_funct3 <= IDEX_funct3;
		EXMEM_PC <= IDEX_PC;
		//CSR
		EXMEM_csr_out <= IDEX_csr_out;
		EXMEM_csr_write <= IDEX_csr_write;
		EXMEM_csr_read_addr <= IDEX_csr_read_addr;
	end
end
//------------------------------MEM------------------------------//

assign DM_OE = EXMEM_MemRead;
assign DM_addr = (DM_CS) ? EXMEM_ALU_result : 32'd0;
 
assign DM_CS = (~DM_WEB[0]) | (~DM_WEB[1]) | (~DM_WEB[2]) | (~DM_WEB[3]) | DM_OE;

//assign PCSrc = EXMEM_Branch & EXMEM_ALU_zero;

always@(posedge clk, posedge rst)begin
	if(rst)begin
		PCSrc_ <= 1'b0;
	end
	else if(~CPU_Ready)begin
		PCSrc_ <= PCSrc_;
	end
	else begin
		PCSrc_ <= PCSrc;
	end
end
always@(posedge clk, posedge rst)begin
	if(rst)begin
		PCSrc__ <= 1'b0;
	end
	else if(~CPU_Ready)begin
		PCSrc__ <= PCSrc__;
	end
	else begin
		PCSrc__ <= PCSrc_;
	end
end
assign PCSrc = IDEX_Branch & EX_Jump;
assign PCSrc2 = PCSrc || PCSrc_;
assign PCSrc3 = PCSrc || PCSrc_ || PCSrc__;


LW_MUX LW_MUX_1(.LW_input(DM_output), 
				.funct3(EXMEM_funct3), 
				.alu2bit(EXMEM_ALU_result[1:0]), 
				.LW_output(LW_out));

SW_MUX SW_MUX_1(.SW_MUX_in(EXMEM_read_data2), 
				.funct3(EXMEM_funct3), 
				.alu2bit(EXMEM_ALU_result[1:0]), 
				.SW_MUX_out(DM_input));

SW_controller SW_controller_1(.sw_en(EXMEM_MemWrite), 
							  .funct3(EXMEM_funct3), 
							  .alu2bit(EXMEM_ALU_result[1:0]), 
							  .memwrite(DM_WEB));
//######################//
//CSR
always@(*)begin
	if(EXMEM_csr_write)begin
		EXMEM_ALU_result = EXMEM_csr_out;
	end
	else begin
		EXMEM_ALU_result = EXMEM_ALU_result_;
	end
end
//######################//

//------------------------------MEM/WB------------------------------//
always@(posedge clk, posedge rst)begin
	if(rst)begin
		MEMWB_DM_read_data <= 32'd0;
		MEMWB_ALU_result <= 32'd0;
		MEMWB_rd_addr <= 5'd0;
		MEMWB_RegWrite <= 1'd0;
		MEMWB_MemtoReg <= 1'd0;
		MEMWB_PC <= 32'd0;
		//CSR
		MEMWB_csr_out <= 32'd0;
		MEMWB_csr_write <= 1'd0;
	end
	else if(~CPU_Ready)begin
		MEMWB_DM_read_data <= MEMWB_DM_read_data;
		MEMWB_ALU_result <= MEMWB_ALU_result;
		MEMWB_rd_addr <= MEMWB_rd_addr;
		MEMWB_RegWrite <= MEMWB_RegWrite;
		MEMWB_MemtoReg <= MEMWB_MemtoReg;
		MEMWB_PC <= MEMWB_PC;
		//CSR
		MEMWB_csr_out <= MEMWB_csr_out;
		MEMWB_csr_write <= MEMWB_csr_write;
	end
	else begin
		MEMWB_DM_read_data <= LW_out;
		MEMWB_ALU_result <= EXMEM_ALU_result;
		MEMWB_rd_addr <= EXMEM_rd_addr;
		MEMWB_RegWrite <= EXMEM_RegWrite;
		MEMWB_MemtoReg <= EXMEM_MemtoReg;
		MEMWB_PC <= EXMEM_PC;
		//CSR
		MEMWB_csr_out <= EXMEM_csr_out;
		MEMWB_csr_write <= EXMEM_csr_write;
	end
end

//------------------------------WB------------------------------//
logic [31:0] write_back_data_;///CSR
MUX2x1 MUX2x1_3(.mux_input1(MEMWB_ALU_result), 
				.mux_input2(MEMWB_DM_read_data), 
				.sel(MEMWB_MemtoReg), 
				.mux_output(write_back_data_));///CSR

//######################//
//CSR
always@(*)begin
	if(MEMWB_csr_write)begin
		write_back_data = MEMWB_csr_out;
	end
	else begin
		write_back_data = write_back_data_;
	end
end
//######################//

endmodule
