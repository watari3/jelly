// ---------------------------------------------------------------------------
//  Jelly  -- the system on fpga system
//
//                                 Copyright (C) 2008-2016 by Ryuji Fuchikami
//                                 http://homepage3.nifty.com/ryuz/
//                                 https://github.com/ryuz/jelly.git
// ---------------------------------------------------------------------------



`timescale 1ns / 1ps
`default_nettype none



module jelly_texture_cache_l2
		#(
			parameter	CACHE_NUM            = 1,
			
			parameter	COMPONENT_NUM        = 3,
			parameter	COMPONENT_DATA_WIDTH = 8,
			
			parameter	DATA_WIDTH           = COMPONENT_NUM * COMPONENT_DATA_WIDTH,
			parameter	STRB_WIDTH           = COMPONENT_NUM,
			
			parameter	USER_WIDTH           = 1,
			
			parameter	S_ADDR_X_WIDTH       = 12,
			parameter	S_ADDR_Y_WIDTH       = 12,
			parameter	S_DATA_WIDTH         = 24,
			
			parameter	TAG_ADDR_WIDTH       = 6,
			
			parameter	BLK_X_SIZE           = 3,	// 0:1pixel, 1:2pixel, 2:4pixel, 3:8pixel ...
			parameter	BLK_Y_SIZE           = 3,	// 0:1pixel, 1:2pixel, 2:4pixel, 3:8pixel ...
			
			parameter	PIX_ADDR_X_WIDTH     = BLK_X_SIZE,
			parameter	PIX_ADDR_Y_WIDTH     = BLK_Y_SIZE,
			parameter	BLK_ADDR_X_WIDTH     = S_ADDR_X_WIDTH - BLK_X_SIZE,
			parameter	BLK_ADDR_Y_WIDTH     = S_ADDR_Y_WIDTH - BLK_Y_SIZE,
			
			parameter	M_DATA_WIDE_SIZE     = 0,
			
			parameter	M_ADDR_X_WIDTH       = BLK_ADDR_X_WIDTH,
			parameter	M_ADDR_Y_WIDTH       = BLK_ADDR_Y_WIDTH,
			parameter	M_DATA_WIDTH         = (S_DATA_WIDTH << M_DATA_WIDE_SIZE),
			
			parameter	USE_M_RREADY         = 0,	// 0: m_rready is always 1'b1.   1: handshake mode.
			
			parameter	BORDER_DATA          = {S_DATA_WIDTH{1'b0}},
			
			parameter	TAG_RAM_TYPE         = "distributed",
			parameter	MEM_RAM_TYPE         = "block",
			
			
			parameter	ID_WIDTH             = 6,
			parameter	ADDR_WIDTH           = 24,
			
			parameter	M_AXI4_ID_WIDTH      = ID_WIDTH,
			parameter	M_AXI4_ADDR_WIDTH    = 32,
			parameter	M_AXI4_DATA_SIZE     = 2,	// 0:8bit, 1:16bit, 2:32bit ...
			parameter	M_AXI4_DATA_WIDTH    = (8 << M_AXI4_DATA_SIZE),
			parameter	M_AXI4_LEN_WIDTH     = 8,
			parameter	M_AXI4_QOS_WIDTH     = 4,
			parameter	M_AXI4_ARID          = {M_AXI4_ID_WIDTH{1'b0}},
			parameter	M_AXI4_ARSIZE        = M_AXI4_DATA_SIZE,
			parameter	M_AXI4_ARBURST       = 2'b01,
			parameter	M_AXI4_ARLOCK        = 1'b0,
			parameter	M_AXI4_ARCACHE       = 4'b0001,
			parameter	M_AXI4_ARPROT        = 3'b000,
			parameter	M_AXI4_ARQOS         = 0,
			parameter	M_AXI4_ARREGION      = 4'b0000,
			
			parameter	M_AXI4_REGS          = 1
		)
		(
			input	wire											reset,
			input	wire											clk,
			
			input	wire											endian,
			
			input	wire	[M_AXI4_ADDR_WIDTH*COMPONENT_NUM-1:0]	param_addr,
			input	wire	[M_AXI4_LEN_WIDTH-1:0]					param_arlen,
			
			input	wire											clear_start,
			output	wire											clear_busy,
			
			input	wire	[S_ADDR_X_WIDTH-1:0]					param_width,
			input	wire	[S_ADDR_X_WIDTH-1:0]					param_height,
			
			
			input	wire	[CACHE_NUM*USER_WIDTH-1:0]				s_aruser,
			input	wire	[CACHE_NUM*S_ADDR_X_WIDTH-1:0]			s_araddrx,
			input	wire	[CACHE_NUM*S_ADDR_Y_WIDTH-1:0]			s_araddry,
			input	wire	[CACHE_NUM-1:0]							s_arvalid,
			output	wire	[CACHE_NUM-1:0]							s_arready,
			
			output	wire	[CACHE_NUM*USER_WIDTH-1:0]				s_ruser,
			output	wire	[CACHE_NUM*S_DATA_WIDTH-1:0]			s_rdata,
			output	wire	[CACHE_NUM-1:0]							s_rvalid,
			input	wire	[CACHE_NUM-1:0]							s_rready,
			
			
			// AXI4 read (master)
			output	wire	[M_AXI4_ID_WIDTH-1:0]					m_axi4_arid,
			output	wire	[M_AXI4_ADDR_WIDTH-1:0]					m_axi4_araddr,
			output	wire	[M_AXI4_LEN_WIDTH-1:0]					m_axi4_arlen,
			output	wire	[2:0]									m_axi4_arsize,
			output	wire	[1:0]									m_axi4_arburst,
			output	wire	[0:0]									m_axi4_arlock,
			output	wire	[3:0]									m_axi4_arcache,
			output	wire	[2:0]									m_axi4_arprot,
			output	wire	[M_AXI4_QOS_WIDTH-1:0]					m_axi4_arqos,
			output	wire	[3:0]									m_axi4_arregion,
			output	wire											m_axi4_arvalid,
			input	wire											m_axi4_arready,
			input	wire	[M_AXI4_ID_WIDTH-1:0]					m_axi4_rid,
			input	wire	[M_AXI4_DATA_WIDTH-1:0]					m_axi4_rdata,
			input	wire	[1:0]									m_axi4_rresp,
			input	wire											m_axi4_rlast,
			input	wire											m_axi4_rvalid,
			output	wire											m_axi4_rready
		);
	
	genvar	i;
	
	
	// -----------------------------
	//  L2 Cahce
	// -----------------------------
	
	localparam AR_DATA_WIDTH = M_ADDR_X_WIDTH + M_ADDR_Y_WIDTH;
	localparam R_DATA_WIDTH  = 1 + COMPONENT_NUM + M_DATA_WIDTH;
	
	
	wire	[CACHE_NUM-1:0]						cache_clear_busy;
	
	wire	[(CACHE_NUM+1)-1:0]					ringbus_ar_id_to;
	wire	[(CACHE_NUM+1)*ID_WIDTH-1:0]		ringbus_ar_id_from;
	wire	[(CACHE_NUM+1)*AR_DATA_WIDTH-1:0]	ringbus_ar_data;
	wire	[(CACHE_NUM+1)-1:0]					ringbus_ar_valid;
	wire	[(CACHE_NUM+1)-1:0]					ringbus_ar_ready;
	
	wire	[(CACHE_NUM+1)*ID_WIDTH-1:0]		ringbus_r_id_to;
	wire	[(CACHE_NUM+1)-1:0]					ringbus_r_id_from;
	wire	[(CACHE_NUM+1)*R_DATA_WIDTH-1:0]	ringbus_r_data;
	wire	[(CACHE_NUM+1)-1:0]					ringbus_r_valid;
	wire	[(CACHE_NUM+1)-1:0]					ringbus_r_ready;
	
	generate
	for ( i = 0; i < CACHE_NUM; i = i+1 ) begin : cahce_loop
		
		// cache
		wire	[M_ADDR_X_WIDTH-1:0]	m_araddrx;
		wire	[M_ADDR_Y_WIDTH-1:0]	m_araddry;
		wire							m_arvalid;
		wire							m_arready;
		
		wire							m_rlast;
		wire	[COMPONENT_NUM-1:0]		m_rstrb;
		wire	[M_DATA_WIDTH-1:0]		m_rdata;
		wire							m_rvalid;
		wire							m_rready;
		
		jelly_texture_cache_unit
			#(
				.USER_WIDTH			(USER_WIDTH),
				
				.COMPONENT_NUM		(COMPONENT_NUM),
				.COMPONENT_WIDTH	(COMPONENT_DATA_WIDTH),
				
				.S_ADDR_X_WIDTH		(S_ADDR_X_WIDTH),
				.S_ADDR_Y_WIDTH		(S_ADDR_Y_WIDTH),
				.S_DATA_WIDTH		(S_DATA_WIDTH),
				
				.TAG_ADDR_WIDTH		(TAG_ADDR_WIDTH),
				
				.BLK_X_SIZE			(BLK_X_SIZE),
				.BLK_Y_SIZE			(BLK_Y_SIZE),
				
				.M_DATA_WIDE_SIZE	(M_DATA_WIDE_SIZE),
				
				.USE_M_RREADY		(USE_M_RREADY),
				
				.BORDER_DATA		(BORDER_DATA),
				
				.TAG_RAM_TYPE		(TAG_RAM_TYPE),
				.MEM_RAM_TYPE		(MEM_RAM_TYPE)
			)
		i_texture_cache_unit
			(
				.reset				(reset),
				.clk				(clk),
				
				.endian				(endian),
				
				.clear_start		(clear_start),
				.clear_busy			(cache_clear_busy[i]),
				
				.param_width		(param_width),
				.param_height		(param_height),
				
				.s_aruser			(s_aruser [i*USER_WIDTH     +: USER_WIDTH]),
				.s_araddrx			(s_araddrx[i*S_ADDR_X_WIDTH +: S_ADDR_X_WIDTH]),
				.s_araddry			(s_araddry[i*S_ADDR_Y_WIDTH +: S_ADDR_Y_WIDTH]),
				.s_arvalid			(s_arvalid[i]),
				.s_arready			(s_arready[i]),
				
				.s_ruser			(s_ruser  [i*USER_WIDTH     +: USER_WIDTH]),
				.s_rdata			(s_rdata  [i*S_DATA_WIDTH   +: S_DATA_WIDTH]),
				.s_rvalid			(s_rvalid [i]),
				.s_rready			(s_rready [i]),
				
				.m_araddrx			(m_araddrx),
				.m_araddry			(m_araddry),
				.m_arvalid			(m_arvalid),
				.m_arready			(m_arready),
				
				.m_rlast			(m_rlast),
				.m_rstrb			(m_rstrb),
				.m_rdata			(m_rdata),
				.m_rvalid			(m_rvalid),
				.m_rready			(m_rready)
			);
		
		
		jelly_ring_bus_unit
				#(
					.DATA_WIDTH		(AR_DATA_WIDTH),
					.ID_TO_WIDTH	(1),
					.ID_FROM_WIDTH	(ID_WIDTH),
					.UNIT_ID_TO		(1),
					.UNIT_ID_FROM	(i)
				)
			i_ring_bus_unit_ar
				(
					.reset			(reset),
					.clk			(clk),
					.cke			(1'b1),
					
					.s_id_to		(1'b0),
					.s_data			({m_araddry, m_araddrx}),
					.s_valid		(m_arvalid),
					.s_ready		(m_arready),
					
					.m_id_from		(),
					.m_data			(),
					.m_valid		(),
					.m_ready		(1'b0),
					
					.src_id_to		(ringbus_ar_id_to  [(i+0)]),
					.src_id_from	(ringbus_ar_id_from[(i+0)*ID_WIDTH      +: ID_WIDTH]),
					.src_data		(ringbus_ar_data   [(i+0)*AR_DATA_WIDTH +: AR_DATA_WIDTH]),
					.src_valid		(ringbus_ar_valid  [(i+0)]),
					
					.sink_id_to		(ringbus_ar_id_to  [(i+1)]),
					.sink_id_from	(ringbus_ar_id_from[(i+1)*ID_WIDTH      +: ID_WIDTH]),
					.sink_data		(ringbus_ar_data   [(i+1)*AR_DATA_WIDTH +: AR_DATA_WIDTH]),
					.sink_valid		(ringbus_ar_valid  [(i+1)])
				);
		
		jelly_ring_bus_unit
				#(
					.DATA_WIDTH		(R_DATA_WIDTH),
					.ID_TO_WIDTH	(ID_WIDTH),
					.ID_FROM_WIDTH	(1),
					.UNIT_ID_TO		(i),
					.UNIT_ID_FROM	(1)
				)
			i_ring_bus_unit_r
				(
					.reset			(reset),
					.clk			(clk),
					.cke			(1'b1),
					
					.s_id_to		(0),
					.s_data			(0),
					.s_valid		(1'b0),
					.s_ready		(),
					
					.m_id_from		(),
					.m_data			({m_rlast, m_rstrb, m_rdata}),
					.m_valid		(m_rvalid),
					.m_ready		(m_rready),
					
					.src_id_to		(ringbus_r_id_to  [(i+0)*ID_WIDTH     +: ID_WIDTH]),
					.src_id_from	(ringbus_r_id_from[(i+0)]),
					.src_data		(ringbus_r_data   [(i+0)*R_DATA_WIDTH +: R_DATA_WIDTH]),
					.src_valid		(ringbus_r_valid  [(i+0)]),
					
					.sink_id_to		(ringbus_r_id_to  [(i+1)*ID_WIDTH     +: ID_WIDTH]),
					.sink_id_from	(ringbus_r_id_from[(i+1)]),
					.sink_data		(ringbus_r_data   [(i+1)*R_DATA_WIDTH +: R_DATA_WIDTH]),
					.sink_valid		(ringbus_r_valid  [(i+1)])
				);
	end
	endgenerate
	
	
	// ring-bus
	wire	[ID_WIDTH-1:0]			ringbus_arid;
	wire	[M_ADDR_X_WIDTH-1:0]	ringbus_araddrx;
	wire	[M_ADDR_Y_WIDTH-1:0]	ringbus_araddry;
	wire							ringbus_arvalid;
	wire							ringbus_arready;
	
	wire	[ID_WIDTH-1:0]			ringbus_rid;
	wire							ringbus_rlast;
	wire	[COMPONENT_NUM-1:0]		ringbus_rstrb;
	wire	[M_DATA_WIDTH-1:0]		ringbus_rdata;
	wire							ringbus_rvalid;
	wire							ringbus_rready;
	
	jelly_ring_bus_unit
				#(
					.DATA_WIDTH		(AR_DATA_WIDTH),
					.ID_TO_WIDTH	(1),
					.ID_FROM_WIDTH	(ID_WIDTH),
					.UNIT_ID_TO		(0),
					.UNIT_ID_FROM	(0)
				)
			i_ring_bus_unit_ar
				(
					.reset			(reset),
					.clk			(clk),
					.cke			(1'b1),
					
					.s_id_to		(0),
					.s_data			(0),
					.s_valid		(1'b0),
					.s_ready		(),
					
					.m_id_from		(ringbus_arid),
					.m_data			({ringbus_araddry, ringbus_araddrx}),
					.m_valid		(ringbus_arvalid),
					.m_ready		(ringbus_arready),
					
					.src_id_to		(ringbus_ar_id_to  [CACHE_NUM]),
					.src_id_from	(ringbus_ar_id_from[CACHE_NUM*ID_WIDTH      +: ID_WIDTH]),
					.src_data		(ringbus_ar_data   [CACHE_NUM*AR_DATA_WIDTH +: AR_DATA_WIDTH]),
					.src_valid		(ringbus_ar_valid  [CACHE_NUM]),
					
					.sink_id_to		(ringbus_ar_id_to  [0]),
					.sink_id_from	(ringbus_ar_id_from[0 +: ID_WIDTH]),
					.sink_data		(ringbus_ar_data   [0 +: AR_DATA_WIDTH]),
					.sink_valid		(ringbus_ar_valid  [0])
				);
	
	jelly_ring_bus_unit
				#(
					.DATA_WIDTH		(R_DATA_WIDTH),
					.ID_TO_WIDTH	(ID_WIDTH),
					.ID_FROM_WIDTH	(1),
					.UNIT_ID_TO		(0),
					.UNIT_ID_FROM	(0)
				)
			i_ring_bus_unit_dma_r
				(
					.reset			(reset),
					.clk			(clk),
					.cke			(1'b1),
					
					.s_id_to		(ringbus_rid),
					.s_data			({ringbus_rlast, ringbus_rstrb, ringbus_rdata}),
					.s_valid		(ringbus_rvalid),
					.s_ready		(ringbus_rready),
					
					.m_id_from		(),
					.m_data			(),
					.m_valid		(),
					.m_ready		(1'b0),
					
					.src_id_to		(ringbus_r_id_to  [CACHE_NUM*ID_WIDTH     +: ID_WIDTH]),
					.src_id_from	(ringbus_r_id_from[CACHE_NUM]),
					.src_data		(ringbus_r_data   [CACHE_NUM*R_DATA_WIDTH +: R_DATA_WIDTH]),
					.src_valid		(ringbus_r_valid  [CACHE_NUM]),
					
					.sink_id_to		(ringbus_r_id_to  [0 +: ID_WIDTH]),
					.sink_id_from	(ringbus_r_id_from[0]),
					.sink_data		(ringbus_r_data   [0 +: R_DATA_WIDTH]),
					.sink_valid		(ringbus_r_valid  [0])
				);
	
	
	
	
	// DMA
	wire	[ID_WIDTH-1:0]			s_dma_id;
	wire	[ADDR_WIDTH-1:0]		s_dma_addr;
	wire							s_dma_valid;
	wire							s_dma_ready;
	
	wire	[ID_WIDTH-1:0]			m_dma_id;
	wire							m_dma_last;
	wire	[STRB_WIDTH-1:0]		m_dma_strb;
	wire	[DATA_WIDTH-1:0]		m_dma_data;
	wire							m_dma_valid;
	wire							m_dma_ready;
	
	jelly_texture_cache_dma
			#(
				.COMPONENT_NUM			(COMPONENT_NUM),
				.COMPONENT_DATA_WIDTH	(COMPONENT_DATA_WIDTH),
				
				.DATA_WIDTH				(DATA_WIDTH),
				.STRB_WIDTH				(STRB_WIDTH),
				
				.ID_WIDTH				(ID_WIDTH),
				.ADDR_WIDTH				(ADDR_WIDTH),
				
				.M_AXI4_ID_WIDTH		(M_AXI4_ID_WIDTH),
				.M_AXI4_ADDR_WIDTH		(M_AXI4_ADDR_WIDTH),
				.M_AXI4_DATA_SIZE		(M_AXI4_DATA_SIZE),
				.M_AXI4_DATA_WIDTH		(M_AXI4_DATA_WIDTH),
				.M_AXI4_LEN_WIDTH		(M_AXI4_LEN_WIDTH),
				.M_AXI4_QOS_WIDTH		(M_AXI4_QOS_WIDTH),
				.M_AXI4_ARID			(M_AXI4_ARID),
				.M_AXI4_ARSIZE			(M_AXI4_ARSIZE),
				.M_AXI4_ARBURST			(M_AXI4_ARBURST),
				.M_AXI4_ARLOCK			(M_AXI4_ARLOCK),
				.M_AXI4_ARCACHE			(M_AXI4_ARCACHE),
				.M_AXI4_ARPROT			(M_AXI4_ARPROT),
				.M_AXI4_ARQOS			(M_AXI4_ARQOS),
				.M_AXI4_ARREGION		(M_AXI4_ARREGION),
				
				.SLAVE_REGS				(1),
				.MASTER_REGS			(1),
				.M_AXI4_REGS			(M_AXI4_REGS)
			)
		i_texture_cache_dma
			(
				.reset					(reset),
				.clk					(clk),
				                         
				.param_addr				(param_addr),
				.param_arlen			(param_arlen),
				
				.s_id					(s_dma_id),
				.s_addr					(s_dma_addr),
				.s_valid				(s_dma_valid),
				.s_ready				(s_dma_ready),
				
				.m_id					(m_dma_id),
				.m_last					(m_dma_last),
				.m_strb					(m_dma_strb),
				.m_data					(m_dma_data),
				.m_valid				(m_dma_valid),
				.m_ready				(m_dma_ready),
				
				.m_axi4_arid			(m_axi4_arid),
				.m_axi4_araddr			(m_axi4_araddr),
				.m_axi4_arlen			(m_axi4_arlen),
				.m_axi4_arsize			(m_axi4_arsize),
				.m_axi4_arburst			(m_axi4_arburst),
				.m_axi4_arlock			(m_axi4_arlock),
				.m_axi4_arcache			(m_axi4_arcache),
				.m_axi4_arprot			(m_axi4_arprot),
				.m_axi4_arqos			(m_axi4_arqos),
				.m_axi4_arregion		(m_axi4_arregion),
				.m_axi4_arvalid			(m_axi4_arvalid),
				.m_axi4_arready			(m_axi4_arready),
				.m_axi4_rid				(m_axi4_rid),
				.m_axi4_rdata			(m_axi4_rdata),
				.m_axi4_rresp			(m_axi4_rresp),
				.m_axi4_rlast			(m_axi4_rlast),
				.m_axi4_rvalid			(m_axi4_rvalid),
				.m_axi4_rready			(m_axi4_rready)
			);
	
	assign s_dma_id        = ringbus_arid;
	assign s_dma_addr      = ({ringbus_araddry, ringbus_araddrx} << (BLK_Y_SIZE + BLK_X_SIZE));
	assign s_dma_valid     = ringbus_arvalid;
	assign ringbus_arready = s_dma_ready;
	
	assign ringbus_rid     = m_dma_id;
	assign ringbus_rlast   = m_dma_last;
	assign ringbus_rstrb   = m_dma_strb;
	assign ringbus_rdata   = m_dma_data;
	assign ringbus_rvalid  = m_dma_valid;
	assign m_dma_ready     = ringbus_rready;
	
	
endmodule


`default_nettype wire


// end of file