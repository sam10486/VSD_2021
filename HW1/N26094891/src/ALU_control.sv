`include "define.sv"


module ALU_control (
    input logic [3:0] ALUop,
    input logic [31:0] instruction,
    output logic [3:0] ALU_control
);

logic [6:0] funct7;
logic [2:0] funct3;
logic [6:0] EX_opcode; // debug

assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
assign EX_opcode = instruction[6:0]; // debug

always_comb begin
    case(ALUop)
        `ALUop_R: begin
            case(funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000) begin
                        ALU_control = `ADD;
                    end else begin
                        ALU_control = `SUB;
                    end
                end
                3'b001: ALU_control = `SLL;
                3'b010: ALU_control = `SLT;
                3'b011: ALU_control = `SLTU;
                3'b100: ALU_control = `XOR;
                3'b101: begin
                    if (funct7 == 7'd0) begin
                        ALU_control = `SRL;
                    end else begin
                        ALU_control = `SRA;
                    end
                end
                3'b110: ALU_control = `OR;
                3'b111: ALU_control = `AND;
            endcase
        end
        `ALUop_I: begin
            case(funct3)
                3'b000: ALU_control = `ADD;
                3'b010: ALU_control = `SLT;
                3'b011: ALU_control = `SLTU;
                3'b100: ALU_control = `XOR;
                3'b110: ALU_control = `OR;
                3'b111: ALU_control = `AND;
                ///
                3'b001: ALU_control = `SLL;
                3'b101: begin
                    if (funct7 == 7'd0) begin
                        ALU_control = `SRL;
                    end else begin
                        ALU_control = `SRA;
                    end
                end
            endcase
        end
        `ALUop_LW: ALU_control = `ADD;
        `ALUop_I_J: ALU_control = `ADD;
        `ALUop_SW: ALU_control = `ADD;
        `ALUop_B: begin
            case(funct3)
                3'b000: ALU_control = `EQ;
                3'b001: ALU_control = `EQ;  //  not equal
                3'b100: ALU_control = `SLT; //  rs1 < rs2 
                3'b101: ALU_control = `SLT; //  rs1 >= rs2
                3'b110: ALU_control = `SLTU;    //rs1u < rs2u
                3'b111: ALU_control = `SLTU;    //rs1u >= rs2u
                default: begin
                    ALU_control = `AND;
                end
            endcase
        end
        default: begin
            ALU_control = `ADD;
        end
    endcase
end
    
endmodule