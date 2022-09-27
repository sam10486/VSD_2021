module CSR (
	input [31:0] PC,
	input clk,
	input rst,
	input WFI,
	input CPU_READY,
	input stall,
	input ID_Branch,
	output logic interrupt_taken,
	input interrupt_return,
	input interrupt,
    input csr_write,
    input [11:0] csr_write_addr,
    input [11:0] csr_read_addr,
    input [31:0] csr_in,
    output logic [31:0] csr_pc,
    output logic [31:0] csr_read_out
);

logic [31:0] mstatus;
logic [31:0] mie;
logic [31:0] mtvec;
logic [31:0] mepc;
logic [31:0] mip;
logic [31:0] mcycle;
logic [31:0] minstret;
logic [31:0] mcycleh;
logic [31:0] minstreth;
logic [31:0] PC_cmpr;

logic 		 mie_11, MIE, MPIE;

assign	mie_11 = mie[11];
assign	MIE = mstatus[3];
assign	MPIE = mstatus[7];


always_comb begin
	if(WFI) begin
		if(interrupt && mie_11 && CPU_READY && ~stall) begin
			interrupt_taken = 1'b1;
		end
		else begin
			interrupt_taken = 1'b0;
		end
	end
	else begin
		if(interrupt && mie_11 && MIE && CPU_READY && ~stall /*&& ~ID_Branch*/) begin
			interrupt_taken = 1'b1;
		end
		else begin
			interrupt_taken = 1'b0;
		end
	end
end

assign mip = {20'd0, interrupt, 11'd0};

always_ff @( posedge clk or posedge rst ) begin
    if (rst) begin
        mstatus <= 32'd0;
        mie <= 32'd0;
        mtvec <= 32'h0001_0000;
        mepc <= 32'd0;
        //mip <= 32'd0;
        mcycle <= 32'd0;
        mcycleh <= 32'd0;
        minstret <= 32'd0;
        minstreth <= 32'd0;
		PC_cmpr <= 32'd0;
    end else begin
        PC_cmpr <= PC;
        if (interrupt_taken) begin
            mstatus <= {19'd0, 2'b11, 3'd0, mstatus[3], 3'd0, 1'd0, 3'd0};
            mie <= mie;
            mtvec <= mtvec;
			mepc <= PC; //--------****
            //mip <= {20'd0, interrupt, 11'd0};
            mcycle <= mcycle;
            mcycleh <= mcycleh;
            minstret <= minstret;
            minstreth <= minstreth;
        end else if (interrupt_return && CPU_READY && ~stall) begin
            mstatus <= {19'd0, 2'b11, 3'd0, 1'b1, 3'd0, mstatus[7], 3'd0};
            mie <= mie;
            mtvec <= mtvec;
            mepc <=  mepc; //--------****
            //mip <= {20'd0, interrupt, 11'd0};
            mcycle <= mcycle;
            mcycleh <= mcycleh;
            minstret <= minstret;
            minstreth <= minstreth;
        end else if (csr_write) begin
            case(csr_write_addr)
                12'h300: mstatus <= {19'd0, csr_in[12:11], 3'b0, csr_in[7], 3'd0, csr_in[3], 3'd0};
                12'h304: mie <= {20'd0, csr_in[11], 11'd0};
                12'h305: mtvec <= mtvec;
                12'h341: mepc <= {csr_in[31:2], 2'b00};
                //12'h344: mip <= {20'd0, interrupt, 11'd0};
                12'hB00: mcycle <= csr_in;
                12'hB02: minstret <= csr_in;
                12'hB80: mcycleh <= csr_in;
                12'hB82: minstreth <= csr_in;
                default: mtvec <= mtvec;
            endcase
        end else begin
            mstatus <= mstatus;
            mie <= mie;
            mtvec <= mtvec;
            mepc <= mepc; //--------****
            //mip <= mip;
            mcycle <= mcycle;
            mcycleh <= mcycleh;
            minstret <= minstret;
            minstreth <= minstreth;
        end

        if (mcycle == 32'hffff_ffff) begin
            mcycle <= 32'd0;
            mcycleh <= mcycleh + 32'b1;
        end else begin
            mcycle <= mcycle + 32'b1;
            mcycleh <= mcycleh;
        end

        if (PC_cmpr != PC) begin
            if (minstret == 32'hffff_ffff) begin
                minstret <= 32'h0;
                minstreth <= minstreth + 32'd1;
            end else begin
                minstret <= minstret + 32'd1;
                minstreth <= minstreth;
            end
        end else begin
            minstret <= minstret;
            minstreth <= minstreth;
        end
    end
end

/*
always_ff @( posedge clk or posedge rst ) begin
    if (interrupt_taken) begin
        csr_pc <= mtvec;
    end else if (interrupt_return) begin
        csr_pc <= mepc;
    end else begin
        csr_pc <= csr_pc;
    end
end
*/

always_comb begin
    if (interrupt_taken) begin
        csr_pc = mtvec;
    end else if (interrupt_return) begin
        csr_pc = mepc;
    end else begin
        csr_pc = 32'd0;
    end
end

always_comb begin
    case(csr_read_addr)
        12'h300: csr_read_out = mstatus;
        12'h304: csr_read_out = mie;
        12'h305: csr_read_out = mtvec;
        12'h341: csr_read_out = mepc;
        12'h344: csr_read_out = mip;
        12'hB00: csr_read_out = mcycle;
        12'hB02: csr_read_out = minstret;
        12'hB80: csr_read_out = mcycleh;
        12'hB82: csr_read_out = minstreth;
        default: csr_read_out = 32'd0;
    endcase
end

endmodule