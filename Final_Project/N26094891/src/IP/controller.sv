module controller (
    input clk,
    input rst,
    input [1:0] instr,
    input [9:0] fft_addr_out,
    input [9:0] div_addr_out,
    input [9:0] ifft_addr_out,
    output logic sram0_addr_sel,
    output logic [9:0] sram0_addr,
    output logic sram_oe,
    output logic fft_data_sel,
    output logic fft_en,
    output logic ifft_en,
    output logic sram1_addr_sel
);
    enum {RESET, IDLE, A_DATA, A_FFT, A_DIV, B_DATA, B_FFT,B_IFFT} cs, ns;


    logic [9:0] addr_reg;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            cs <= RESET;
            addr_reg <= 10'd0;
        end else begin
            cs <= ns;
            if (cs == A_DATA || cs == B_DATA) begin
                addr_reg <= addr_reg + 10'd1;
            end else begin
                addr_reg <= 10'd0;
            end
        end
    end

    always_comb begin
        case(cs)
            RESET: begin
                sram0_addr_sel = 1'b0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b0; // 0:training mode; 1:product mode
                fft_en = 1'd0;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                ns = IDLE;
            end
            IDLE: begin
                sram0_addr_sel = 1'b0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b0;
                fft_en = 1'd0;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (instr == 2'b01) begin
                    ns = A_DATA;
                end else if (instr == 2'b10) begin
                    ns = B_DATA;
                end else begin
                    ns = IDLE;
                end
            end
            A_DATA: begin
                sram0_addr_sel = 1'd1;
                sram0_addr = addr_reg;
                sram_oe = 1'd1;
                fft_data_sel = 1'b0;
                fft_en = 1'd1;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (addr_reg == 10'd1023) begin
                    ns = A_FFT;
                end else begin
                    ns = A_DATA;
                end
            end
            A_FFT: begin
                sram0_addr_sel = 1'd0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b0;
                fft_en = 1'd1;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (fft_addr_out == 10'd1023) begin
                    ns = A_DIV;
                end else begin
                    ns = A_FFT;
                end
            end
            A_DIV: begin
                sram0_addr_sel = 1'd0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b0;
                fft_en = 1'd0;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (div_addr_out == 10'd1023) begin
                    ns = IDLE;
                end else begin
                    ns = A_DIV;
                end
            end
            B_DATA: begin
                sram0_addr_sel = 1'd1;
                sram0_addr = addr_reg;
                sram_oe = 1'd1;
                fft_data_sel = 1'b1;
                fft_en = 1'd1;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (addr_reg == 10'd1023) begin
                    ns = B_FFT;
                end else begin
                    ns = B_DATA;
                end
            end
            B_FFT: begin
                sram0_addr_sel = 1'd0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b1;
                fft_en = 1'd1;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                if (fft_addr_out == 10'd1023) begin
                    ns = B_IFFT;
                end else begin
                    ns = B_FFT;
                end
            end
            B_IFFT: begin
                sram0_addr_sel = 1'd0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b1;
                fft_en = 1'd0;
                ifft_en = 1'd1;
                sram1_addr_sel = 1'b1;
                if (ifft_addr_out == 10'd1023) begin
                    ns = IDLE;
                end else begin
                    ns = B_IFFT;
                end
            end
            default: begin
                sram0_addr_sel = 1'd0;
                sram0_addr = 10'd0;
                sram_oe = 1'd0;
                fft_data_sel = 1'b0;
                fft_en = 1'd0;
                ifft_en = 1'd0;
                sram1_addr_sel = 1'b0;
                ns = RESET;
            end
        endcase
    end

endmodule