// ---------------------------------------------------------------------------
//  Jelly  -- the soft-core processor system
//
//
//                                 Copyright (C) 2008-2018 by Ryuji Fuchikami
//                                 http://ryuz.my.coocan.jp/
// ---------------------------------------------------------------------------



`timescale 1ns / 1ps
`default_nettype none


module jelly_video_tbl_modulator
		#(
			parameter	WB_ADR_WIDTH   = 8,
			parameter	WB_DAT_WIDTH   = 32,
			parameter	WB_SEL_WIDTH   = (WB_DAT_WIDTH / 8),
			
			parameter	TUSER_WIDTH    = 1,
			parameter	TDATA_WIDTH    = 24,
			
			parameter	ADDR_WIDTH     = 6,
			parameter	MEM_SIZE       = (1 << ADDR_WIDTH),
			parameter	RAM_TYPE       = "distributed",
			parameter	FILLMEM_DATA   = 127,
			
			parameter	M_SLAVE_REGS   = 1,
			parameter	M_MASTER_REGS  = 1,
			
			parameter	INIT_PARAM_END = 0,
			parameter	INIT_PARAM_INV = 0
		)
		(
			input	wire						aresetn,
			input	wire						aclk,
			input	wire						aclken,
			
			input	wire						s_wb_rst_i,
			input	wire						s_wb_clk_i,
			input	wire	[WB_ADR_WIDTH-1:0]	s_wb_adr_i,
			input	wire	[WB_DAT_WIDTH-1:0]	s_wb_dat_i,
			output	wire	[WB_DAT_WIDTH-1:0]	s_wb_dat_o,
			input	wire						s_wb_we_i,
			input	wire	[WB_SEL_WIDTH-1:0]	s_wb_sel_i,
			input	wire						s_wb_stb_i,
			output	wire						s_wb_ack_o,
			
			input	wire	[TUSER_WIDTH-1:0]	s_axi4s_tuser,
			input	wire						s_axi4s_tlast,
			input	wire	[TDATA_WIDTH-1:0]	s_axi4s_tdata,
			input	wire						s_axi4s_tvalid,
			output	wire						s_axi4s_tready,
			
			output	wire	[TUSER_WIDTH-1:0]	m_axi4s_tuser,
			output	wire						m_axi4s_tlast,
			output	wire	[TDATA_WIDTH-1:0]	m_axi4s_tdata,
			output	wire	[0:0]				m_axi4s_tbinary,
			output	wire						m_axi4s_tvalid,
			input	wire						m_axi4s_tready
		);
	
	
	// register
	localparam	REG_ADDR_PARAM_END  = 32'h04;
	localparam	REG_ADDR_PARAM_INV  = 32'h05;
	
	localparam	REG_ADDR_TBL_START  = (1 << ADDR_WIDTH);
	localparam	REG_ADDR_TBL_END    = REG_ADDR_TBL_START + (MEM_SIZE - 1);
	
	reg		[ADDR_WIDTH-1:0]		reg_param_end;
	reg		[0:0]					reg_param_inv;
	
	always @(posedge s_wb_clk_i) begin
		if ( s_wb_rst_i ) begin
			reg_param_end <= INIT_PARAM_END;
			reg_param_inv <= INIT_PARAM_INV;
		end
		else begin
			if ( s_wb_stb_i && s_wb_we_i ) begin
				case ( s_wb_adr_i )
				REG_ADDR_PARAM_END:	reg_param_end <= s_wb_dat_i;
				REG_ADDR_PARAM_INV:	reg_param_inv <= s_wb_dat_i;
				endcase
			end
		end
	end
	
	reg		[WB_DAT_WIDTH-1:0]	wb_dat_o;
	always @* begin
		wb_dat_o = {WB_DAT_WIDTH{1'b0}};
		case ( s_wb_adr_i )
		REG_ADDR_PARAM_END:	wb_dat_o = reg_param_end;
		REG_ADDR_PARAM_INV:	wb_dat_o = reg_param_inv;
		endcase
	end
	
	assign s_wb_dat_o = wb_dat_o;
	assign s_wb_ack_o = s_wb_stb_i;
	
	
	wire						wr_en   = s_wb_stb_i && (s_wb_adr_i >= REG_ADDR_TBL_START && s_wb_adr_i <= REG_ADDR_TBL_END);
	wire	[ADDR_WIDTH-1:0]	wr_addr = s_wb_adr_i[ADDR_WIDTH-1:0];
	wire	[TDATA_WIDTH-1:0]	wr_din  = s_wb_dat_i[TDATA_WIDTH-1:0];
	
	jelly_video_tbl_modulator_core
			#(
				.TUSER_WIDTH		(TUSER_WIDTH),
				.TDATA_WIDTH		(TDATA_WIDTH),
				.ADDR_WIDTH			(ADDR_WIDTH),
				.MEM_SIZE			(MEM_SIZE),
				.RAM_TYPE			(RAM_TYPE),
				.FILLMEM_DATA		(FILLMEM_DATA),
				.M_SLAVE_REGS		(M_SLAVE_REGS),
				.M_MASTER_REGS		(M_MASTER_REGS)
			)
		i_video_tbl_modulator_core
			(
				.aresetn			(aresetn),
				.aclk				(aclk),
				.aclken				(aclken),
				
				.param_end			(reg_param_end),
				.param_inv			(reg_param_inv),
				
				.wr_clk				(s_wb_clk_i),
				.wr_en				(wr_en),
				.wr_addr			(wr_addr),
				.wr_din				(wr_din),
				
				.s_axi4s_tuser		(s_axi4s_tuser),
				.s_axi4s_tlast		(s_axi4s_tlast),
				.s_axi4s_tdata		(s_axi4s_tdata),
				.s_axi4s_tvalid		(s_axi4s_tvalid),
				.s_axi4s_tready		(s_axi4s_tready),
				
				.m_axi4s_tuser		(m_axi4s_tuser),
				.m_axi4s_tlast		(m_axi4s_tlast),
				.m_axi4s_tdata		(m_axi4s_tdata),
				.m_axi4s_tbinary	(m_axi4s_tbinary),
				.m_axi4s_tvalid		(m_axi4s_tvalid),
				.m_axi4s_tready		(m_axi4s_tready)
			);
	
	
endmodule



`default_nettype wire



// end of file
