`include "define.sv"

module imm_gen (
    input logic [31:0] instruction,
    output logic [31:0] imm
);

logic [6:0] imm_type;
assign imm_type = instruction[6:0];

always_comb begin
    case(imm_type)
        `R_type:                    imm = 32'd0;
        `I_type,`I_type_J,`LW:      imm = {{20{instruction[31]}},instruction[31:20]};
        `SW:                        imm = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; 
        `B_type:                    imm = {{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'd0};
        `U_type,`U_type_L:          imm = {instruction[31:12],12'd0};
        `J_type:                    imm = {{12{instruction[31]}},instruction[19:12],instruction[20],instruction[30:21],1'd0};
        default: begin
            imm = 32'd0;
        end
    endcase
end
    
endmodule