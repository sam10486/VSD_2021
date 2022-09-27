`include "../include/AXI_define.svh"
/*`define ACT     		4'b0000
`define IDLE  			4'b0001
`define Read_pre 		4'b0010
`define RAddr_col		4'b0011
`define RData  			4'b0100
`define Read_handshake	4'b0101 
`define Write_pre		4'b0110 
`define WAddr_col		4'b0111
//`define	WData			4'b1000
`define	WResp			4'b1001
*/

module DRAM_wrapper (
    input ACLK,
	input ARESETn,

    //WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,  
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY, 
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic[`AXI_IDS_BITS-1:0] RID,
	output logic[`AXI_DATA_BITS-1:0] RDATA,
	output logic[1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,


    output logic CSn,
    output logic [3:0] WEn,
    output logic RASn,
    output logic CASn,
    output logic [10:0] A,
    output logic [31:0] D,
    input [31:0] Q,
    input valid 
);

//--------parameter-------
//logic [31:0] read_addr_buf, write_addr_buf;
logic [31:0] addr_buf;
logic [31:0] ARADDR_buf,AWADDR_buf;
logic read_row_hit, write_row_hit;
logic [7:0] ARID_buf, AWID_buf;
logic [3:0] WSTRB_buf;

//logic [3:0] cs,ns;

logic [2:0] cnt_read_pre,cnt_write_pre,cnt_act,cnt_write_data;

logic [31:0] Q_buf;

enum {ACT, IDLE, Read_pre, RAddr_col, RData, Read_handshake, Write_pre, WAddr_col, WResp} cs, ns;

always_ff @( posedge ACLK or negedge ARESETn) begin
    if (~ARESETn) begin
		addr_buf <= 32'b0;
        //read_addr_buf <= 32'b1_0000_0000_0000;
        //write_addr_buf <= 32'b1_0000_0000_0000;
    end 
	else if(cs == ACT) begin
		if (ARVALID) begin
            addr_buf <= ARADDR;
        end
        if (AWVALID) begin
            addr_buf <= AWADDR;
        end
		/*
        if (ARVALID) begin
            read_addr_buf <= ARADDR;
        end
        if (AWVALID) begin
            write_addr_buf <= AWADDR;
        end
		*/
    end
end

always_comb begin 
	if(cs == IDLE) begin
		if (addr_buf[22:12] == ARADDR[22:12]) begin
			read_row_hit = 1'b1;
		end 
		else begin
			read_row_hit  = 1'b0;
		end
		if (addr_buf[22:12] == AWADDR[22:12]) begin
			write_row_hit = 1'b1;
		end 
		else begin
			write_row_hit = 1'b0;
		end
	end
	else begin
		read_row_hit = 1'b0;
		write_row_hit = 1'b0;
	end
end

//count
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cnt_read_pre <= 3'd0;
	end
	else begin
		if(cs == Read_pre) begin
			cnt_read_pre <= cnt_read_pre + 3'd1;
		end
		else begin
			cnt_read_pre <= 3'd0;
		end
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cnt_write_pre <= 3'd0;
	end
	else begin
		if(cs == Write_pre) begin
			cnt_write_pre <= cnt_write_pre + 3'd1;
		end
		else begin
			cnt_write_pre <= 3'd0;
		end
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cnt_act <= 3'd0;
	end
	else begin
		if(cs == ACT) begin
			cnt_act <= cnt_act + 3'd1;
		end
		else begin
			cnt_act <= 3'd0;
		end
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
		cnt_write_data <= 3'd0;
	end
	else begin
		if(cs == WAddr_col) begin
			cnt_write_data <= cnt_write_data + 3'd1;
		end
		else begin
			cnt_write_data <= 3'd0;
		end
	end
end

//READ CHANNEL
always_comb begin
	if(cs == RAddr_col) begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end
end

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if (~ARESETn) begin
        ARID_buf 	<= 8'd0;
		ARADDR_buf	<= 32'd0;
    end 
	else if (cs == IDLE) begin
        ARID_buf 	<= ARID;
		ARADDR_buf	<= ARADDR;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if (~ARESETn) begin
		Q_buf <= 32'd0;
	end
	else if(valid) begin
		Q_buf <= Q;
	end
end

always_comb begin 
    if (cs == Read_handshake) begin
        RVALID = 1'd1;
        RRESP = 2'b00;
        RDATA = Q_buf;
        RLAST = 1'b1;
        RID = ARID_buf;
    end 
	else begin
        RVALID = 1'd0;
        RRESP = 2'b00;
        RDATA = 32'd0;
        RLAST = 1'b0;
        RID = 8'd0;
    end
end

//WRITE CHANNEL
always_ff @( posedge ACLK or negedge ARESETn) begin
    if (~ARESETn) begin
        AWID_buf 	<= 8'd0;
		AWADDR_buf	<= 32'd0;
    end 
	else if(cs == IDLE) begin
		AWID_buf 	<= AWID;
		AWADDR_buf	<= AWADDR;
    end
end

always_comb begin
	if((cs == IDLE) && (write_row_hit)) begin
		AWREADY = 1'b1;
	end
	else begin
		AWREADY = 1'b0;
	end
end

always_comb begin
	if(cs == WAddr_col) begin
		if(cnt_write_data == 3'd4) begin
			WREADY = 1'b1;
		end
		else begin
			WREADY = 1'b0;
		end
	end
	else begin
		WREADY = 1'b0;
	end
end

always_comb begin
	if(cs == WResp) begin
		BID		= AWID_buf;
		BRESP	= 2'b00;
		BVALID	= 1'b1;
	end
	else begin
		BID		= 8'b0;
		BRESP	= 2'b11;
		BVALID	= 1'b0;
	end
end


//FSM
always_ff @( posedge ACLK or negedge ARESETn) begin
    if (~ARESETn) begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end

always_comb begin
    case(cs)
		ACT: begin
			if(cnt_act == 3'd4) begin
				ns = IDLE;
			end
			else begin
				ns = ACT;
			end
		end
        IDLE: begin
            if (ARVALID) begin
                if (read_row_hit) begin
                    ns = RAddr_col;
                end else begin
                    ns = Read_pre;
                end
            end else if (AWVALID) begin
                if (write_row_hit) begin
                    ns = WAddr_col;
                end else begin
                    ns = Write_pre;
                end     
            end else begin
                ns = IDLE;
            end
        end
		Read_pre: begin
			if(cnt_read_pre == 3'd4) begin
				ns = ACT;
			end
			else begin
				ns = Read_pre;
			end
		end
        RAddr_col: begin
            if (ARVALID && ARREADY) begin
                ns = RData;
            end else begin
                ns = RAddr_col;
            end
        end
        RData: begin
            if (valid) begin
                ns = Read_handshake;
            end else begin
                ns = RData;
            end
        end
        Read_handshake: begin
            if (RVALID && RREADY && RLAST) begin
                ns = IDLE;
            end else begin
                ns = Read_handshake;
            end
        end
        Write_pre: begin
            if(cnt_write_pre == 3'd4) begin
				ns = ACT;
			end
			else begin
				ns = Write_pre;
			end
        end
        WAddr_col: begin
            if (WVALID && WREADY && WLAST && (cnt_write_data == 3'd4)) begin
                ns = WResp;
            end else begin
                ns = WAddr_col;
            end  
        end
		/*
        `WData: begin
            if (WVALID && WREADY && WLAST) begin
                ns = `WResp;
            end else begin
                ns = `WData;
            end
        end
		*/
		WResp: begin
			if (BVALID && BREADY) begin
				ns = IDLE;
			end
			else begin
				ns = WResp;
			end
		end
        default: ns = IDLE;
    endcase
end


// control signal
assign CSn = 1'b0;
always_comb begin
    case(cs)
		ACT: begin
			if(cnt_act == 3'd0) begin
				if(ARVALID) begin
					A 		= ARADDR_buf[22:12];
				end
				else begin
					A 		= AWADDR_buf[22:12];
				end
				WEn 	= 4'b1111;
				RASn 	= 1'b0;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
			else begin
				A 		= 11'b0;
				WEn 	= 4'b1111;
				RASn 	= 1'b1;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
        end
        IDLE: begin
            A 		= 11'b0;
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= 32'd0;
        end
        Read_pre: begin
			if(cnt_read_pre == 3'd0) begin
				A 		= addr_buf[22:12];
				WEn 	= 4'b0000;
				RASn 	= 1'b0;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
			else begin
				A 		= 11'b0;
				WEn 	= 4'b1111;
				RASn 	= 1'b1;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
        end
        RAddr_col: begin
            A 		= {1'd0, ARADDR_buf[11:2]};
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b0;
            D 		= 32'd0;
        end
        RData: begin
            A 		= 11'd0;
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= 32'd0;
        end
        Read_handshake: begin
            A 		= 11'd0;
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= 32'd0;
        end
        Write_pre: begin
			if(cnt_write_pre == 3'd0) begin
				A 		= addr_buf[22:12];
				WEn 	= 4'b0000;
				RASn 	= 1'b0;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
			else begin
				A 		= 11'b0;
				WEn 	= 4'b1111;
				RASn 	= 1'b1;
				CASn 	= 1'b1;
				D 		= 32'd0;
			end
        end
        WAddr_col: begin
			if(cnt_write_data == 3'd0) begin
				A 		= {1'd0, AWADDR_buf[11:2]};
				WEn 	= WSTRB;
				RASn 	= 1'b1;
				CASn 	= 1'b0;
				D 		= WDATA;
			end
			else begin
				A 		= {1'd0, AWADDR_buf[11:2]};
				WEn 	= 4'b1111;
				RASn 	= 1'b1;
				CASn 	= 1'b1;
				D 		= WDATA;
			end
        end 
		/*
        `WData: begin
            A 		= 11'd0;
            WEn 	= WSTRB;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= WDATA;
        end
		*/
		WResp: begin
            A 		= 11'd0;
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= 32'd0;
        end
        default: begin
            A 		= 11'b0;
            WEn 	= 4'b1111;
            RASn 	= 1'b1;
            CASn 	= 1'b1;
            D 		= 32'd0;
        end
    endcase
end

endmodule
