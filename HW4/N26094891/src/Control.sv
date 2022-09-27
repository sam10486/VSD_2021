`include "define.sv"

module Control (
    input logic [31:0] instruction,
    output logic Branch,
    output logic MemRead,
    output logic [1:0] MemtoReg,
    output logic [3:0] ALUop,
    output logic MemWrite,
    output logic ALUSrc,
    output logic RegWrite,
    output logic JALR,
    output logic PC_imm_ctr,
    output logic Jump,
    output logic Branch_inv,
    output logic LW, LH, LHU, LBU, LB,
    output logic SW, SB, SH
);

logic [6:0] opcode;
logic [2:0] funct3;
assign opcode = instruction[6:0];
assign funct3 = instruction[14:12];

always_comb begin
    case(opcode)
        `LW: begin  //I-type
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd1;
            MemtoReg = 2'b01;
            ALUop = `ALUop_LW;
            MemWrite = 1'd0;
            ALUSrc = 1'd1;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
            case(funct3)
                3'b000: begin
                    LW = 1'd0;
                    LH = 1'd0;
                    LHU = 1'd0;
                    LBU = 1'd0;
                    LB = 1'd1;
                end
                3'b010: begin
                    LW = 1'd1;
                    LH = 1'd0;
                    LHU = 1'd0;
                    LBU = 1'd0;
                    LB = 1'd0;
                end
                3'b001: begin
                    LW = 1'd0;
                    LH = 1'd1;
                    LHU = 1'd0;
                    LBU = 1'd0;
                    LB = 1'd0;
                end
                3'b101: begin
                    LW = 1'd0;
                    LH = 1'd0;
                    LHU = 1'd1;
                    LBU = 1'd0;
                    LB = 1'd0;
                end
                3'b100: begin
                    LW = 1'd0;
                    LH = 1'd0;
                    LHU = 1'd0;
                    LBU = 1'd1;
                    LB = 1'd0;
                end
                default: begin
                    LW = 1'd0;
                    LH = 1'd0;
                    LHU = 1'd0;
                    LBU = 1'd0;
                    LB = 1'd0;
                end
            endcase
        end
        `SW: begin  //S-type
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = `ALUop_SW;
            MemWrite = 1'd1;
            ALUSrc = 1'd1;
            RegWrite = 1'd0;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            case(funct3)
                3'b000: begin
                    SW = 1'd0;
                    SB = 1'd1;
                    SH = 1'd0;
                end
                3'b001: begin
                    SW = 1'd0;
                    SB = 1'd0;
                    SH = 1'd1;
                end
                3'b010: begin
                    SW = 1'd1;
                    SB = 1'd0;
                    SH = 1'd0;
                end
                default: begin
                    SW = 1'd0;
                    SB = 1'd0;
                    SH = 1'd0;
                end
            endcase
        end
        `R_type: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = `ALUop_R;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `I_type: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = `ALUop_I;
            MemWrite = 1'd0;
            ALUSrc = 1'd1;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `I_type_J: begin
            JALR = 1'd1;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b10;
            ALUop = `ALUop_I_J;
            MemWrite = 1'd0;
            ALUSrc = 1'd1;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `B_type: begin
            JALR = 1'd0;
            Branch = 1'd1;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = `ALUop_B;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd0;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            case(funct3)
                3'b000: Branch_inv = 1'd1;
                3'b001: Branch_inv = 1'd0;
                3'b100: Branch_inv = 1'd1;
                3'b101: Branch_inv = 1'd0;
                3'b110: Branch_inv = 1'd1;
                3'b111: Branch_inv = 1'd0;
                default: begin
                    Branch_inv = 1'd0;
                end
            endcase
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `U_type: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b11;
            ALUop = `ALUop_U;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd1; //1:PC_add_imm, 0:imm 
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `U_type_L: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b11;
            ALUop = `ALUop_U_L;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
        `J_type: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b10;
            ALUop = `ALUop_J;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd1;
            Jump = 1'd1;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
		`CSR: begin
			JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = `ALUop_R;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd1;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
		end
        default: begin
            JALR = 1'd0;
            Branch = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 2'b00;
            ALUop = 4'd9;
            MemWrite = 1'd0;
            ALUSrc = 1'd0;
            RegWrite = 1'd0;
            PC_imm_ctr = 1'd0;
            Jump = 1'd0;
            Branch_inv = 1'd0;
            LW = 1'd0;
            LH = 1'd0;
            LHU = 1'd0;
            LBU = 1'd0;
            LB = 1'd0;
            SW = 1'd0;
            SB = 1'd0;
            SH = 1'd0;
        end
    endcase
end

    
endmodule