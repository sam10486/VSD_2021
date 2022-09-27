module CSR(
input clk,
input rst,
input csr_write,
input [11:0] csr_read_addr,
input [11:0] csr_write_addr,
input [31:0] csr_write_data,
output logic [31:0] csr_read_data,
//input interrupt_taken,
output interrupt_taken,
input interrupt_return,
input interrupt,
output logic [31:0] csr_pc,
input wait_for_interrupt,
input [31:0] pc,
input CPU_ready
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

logic [31:0] pc_buff;//?????
logic csr_addr_error;
logic interrupt_taken;
logic MPIE;
assign MPIE = mstatus[7];

logic mie_11;
assign mie_11 = mie[11];
logic mstatus_3;
assign mstatus_3 = mstatus[3];
 
always_comb begin
	if(wait_for_interrupt) begin
		if((mie[11]) && (interrupt) && (CPU_ready))begin
			interrupt_taken = 1'd1;
		end
		else begin
			interrupt_taken = 1'd0;
		end
	end
	else begin
		if((mie[11]) && (mstatus[3]) && (interrupt) && (CPU_ready))begin
			interrupt_taken = 1'd1;
		end
		else begin
			interrupt_taken = 1'd0;
		end
	end
	
end
//-----------write-----------//
always@(posedge clk or posedge rst)begin
	if(rst)begin
		mstatus 	<= 32'd0;
		mie 		<= 32'd0;
		mtvec 		<= 32'h00010000;
		mepc 		<= 32'd0;
		mip 		<= 32'd0;
		mcycle 		<= 32'd0;
		minstret 	<= 32'd0;
		mcycleh 	<= 32'd0;
		minstreth 	<= 32'd0;
		
		pc_buff		<= 32'hf;//?????
		csr_addr_error <= 1'b0;
	end
	else begin
		pc_buff		<= pc;//?????
		mip 		<= {20'd0,interrupt,11'd0};
		mtvec 		<= 32'h00010000;
		if(interrupt_taken)begin
			mstatus 	<= {19'd0, 2'b11, 3'd0, mstatus[3], 3'd0, 1'd0, 3'd0};
			mie 		<= mie;
			mtvec 		<= mtvec;
			mepc 		<= pc;
			mcycle 		<= mcycle;
			minstret 	<= minstret;
			mcycleh 	<= mcycleh;
			minstreth 	<= minstreth;
		end
		else if(interrupt_return && CPU_ready)begin
			mstatus 	<= {19'd0, 2'b11, 3'd0, 1'b1, 3'd0, mstatus[7], 3'd0};
			mie 		<= mie;
			mtvec 		<= mtvec;
			mepc 		<= mepc;
			mcycle 		<= mcycle;
			minstret 	<= minstret;
			mcycleh 	<= mcycleh;
			minstreth 	<= minstreth;
		end
		else if(csr_write)begin
			csr_addr_error <= 1'b0;
			case(csr_write_addr)
				12'h300:mstatus 	<= {19'd0, csr_write_data[12:11], 3'd0, csr_write_data[7], 3'd0, csr_write_data[3], 3'd0};
				12'h304:mie 		<= {20'd0, csr_write_data[11], 11'd0};
				12'h305:mtvec     	<= mtvec;
				12'h341:mepc 		<= {csr_write_data[31:2],2'b00};
				12'hb00:mcycle 		<= csr_write_data;
				12'hb02:minstret 	<= csr_write_data;
				12'hb80:mcycleh 	<= csr_write_data;
				12'hb82:minstreth 	<= csr_write_data;
				default:mtvec     	<= mtvec;
			endcase
		end
		else begin
			mstatus 	<= mstatus;
			mie 		<= mie;
			mtvec 		<= mtvec;
			mepc 		<= mepc;
			mcycle 		<= mcycle;
			minstret 	<= minstret;
			mcycleh 	<= mcycleh;
			minstreth 	<= minstreth;
		end
		
		
		
		
		if (mcycle == 32'hffff_ffff) begin
            mcycle <= 32'd0;
            mcycleh <= mcycleh + 32'b1;
        end else begin
            mcycle <= mcycle + 32'b1;
            mcycleh <= mcycleh;
        end

        if (pc_buff != pc) begin
            if (minstret == 32'hffff_ffff) begin
                minstret <= 32'h0;
                minstreth <= minstreth + 32'd1;
            end else begin
                minstret <= minstret + 32'd1;
                minstreth <= minstreth;
            end
        end
		else begin
            minstret <= minstret;
            minstreth <= minstreth;
        end
	end
end






//-----------read-----------//
always@(*)begin
	if(interrupt_taken)begin
		csr_pc = mtvec;
	end
	else if(interrupt_return)begin
		csr_pc = mepc;
	end
	else begin
		csr_pc = 32'd0;
	end
end

always@(*)begin
	case(csr_read_addr)
		12'h300:csr_read_data = mstatus;
		12'h304:csr_read_data = mie;
		12'h305:csr_read_data = mtvec;
		12'h341:csr_read_data = mepc;
		12'h344:csr_read_data = mip;
		12'hb00:csr_read_data = mcycle;
		12'hb02:csr_read_data = minstret;
		12'hb80:csr_read_data = mcycleh;
		12'hb82:csr_read_data = minstreth;
		default:csr_read_data = 32'hffffffff;//error number
	endcase
end


endmodule