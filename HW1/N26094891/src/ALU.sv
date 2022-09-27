`include "define.sv"

module ALU(
    output logic [31:0] ALU_result, //rd
    output logic ALU_zero,
    input [31:0] ALU_rs1, ALU_rs2,
    input [3:0] ALU_control
);


always @(*) begin
    begin
        case(ALU_control)
            `ADD:   ALU_result = ALU_rs1 + ALU_rs2;   //add
            `SUB:   ALU_result = ALU_rs1 - ALU_rs2;   //sub
            `SLL:   ALU_result = ALU_rs1 << ALU_rs2[4:0]; //sll
            `SLT:   ALU_result = ($signed(ALU_rs1) < $signed(ALU_rs2)) ? 32'd1 : 32'd0; //slt
            `SLTU:  ALU_result = (ALU_rs1 < ALU_rs2) ? 32'd1 : 32'd0; //sltu
            `XOR:   ALU_result = ALU_rs1 ^ ALU_rs2;   //xor
            `SRL:   ALU_result = ALU_rs1 >> ALU_rs2[4:0]; //srl
            `SRA:   ALU_result = $signed(ALU_rs1) >>>  ALU_rs2[4:0]; //sra
            `OR:    ALU_result = ALU_rs1 | ALU_rs2;  //or
            `AND:   ALU_result = ALU_rs1 & ALU_rs2;   //and
            `EQ: begin
                if (ALU_rs1 == ALU_rs2) begin
                    ALU_result = 32'd1;
                end else begin
                    ALU_result = 32'd0;
                end
            end     
            default: begin
                ALU_result = 32'd0;
            end
        endcase
    end
end

always @(*) begin
    if (ALU_result == 32'd0) begin
        ALU_zero = 1'd1;
    end else begin
        ALU_zero = 1'd0;
    end
end

endmodule