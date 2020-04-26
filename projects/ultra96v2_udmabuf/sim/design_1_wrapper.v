
`timescale 1 ns / 1 ps

module design_1_wrapper
        (
            output  wire            out_resetn,
            output  wire            out_clk,
            
            output  wire    [39:0]  m_axi4l_peri_awaddr,
            output  wire    [2:0]   m_axi4l_peri_awprot,
            output  wire            m_axi4l_peri_awvalid,
            input   wire            m_axi4l_peri_awready,
            output  wire    [63:0]  m_axi4l_peri_wdata,
            output  wire    [7:0]   m_axi4l_peri_wstrb,
            output  wire            m_axi4l_peri_wvalid,
            input   wire            m_axi4l_peri_wready,
            input   wire    [1:0]   m_axi4l_peri_bresp,
            input   wire            m_axi4l_peri_bvalid,
            output  wire            m_axi4l_peri_bready,
            output  wire    [39:0]  m_axi4l_peri_araddr,
            output  wire    [2:0]   m_axi4l_peri_arprot,
            output  wire            m_axi4l_peri_arvalid,
            input   wire            m_axi4l_peri_arready,
            output  wire    [63:0]  m_axi4l_peri_rdata,
            output  wire    [1:0]   m_axi4l_peri_rresp,
            output  wire            m_axi4l_peri_rvalid,
            input   wire            m_axi4l_peri_rready,
            
            input   wire    [5:0]   s_axi4_mem0_awid,
            input   wire            s_axi4_mem0_awuser,
            input   wire    [48:0]  s_axi4_mem0_awaddr,
            input   wire    [1:0]   s_axi4_mem0_awburst,
            input   wire    [3:0]   s_axi4_mem0_awcache,
            input   wire    [7:0]   s_axi4_mem0_awlen,
            input   wire    [0:0]   s_axi4_mem0_awlock,
            input   wire    [2:0]   s_axi4_mem0_awprot,
            input   wire    [3:0]   s_axi4_mem0_awqos,
            input   wire    [2:0]   s_axi4_mem0_awsize,
            input   wire            s_axi4_mem0_awvalid,
            output  wire            s_axi4_mem0_awready,
            input   wire    [127:0] s_axi4_mem0_wdata,
            input   wire    [15:0]  s_axi4_mem0_wstrb,
            input   wire            s_axi4_mem0_wlast,
            input   wire            s_axi4_mem0_wvalid,
            output  wire            s_axi4_mem0_wready,
            output  wire    [5:0]   s_axi4_mem0_bid,
            output  wire    [1:0]   s_axi4_mem0_bresp,
            output  wire            s_axi4_mem0_bvalid,
            input   wire            s_axi4_mem0_bready,
            input   wire    [5:0]   s_axi4_mem0_arid,
            input   wire            s_axi4_mem0_aruser,
            input   wire    [48:0]  s_axi4_mem0_araddr,
            input   wire    [1:0]   s_axi4_mem0_arburst,
            input   wire    [3:0]   s_axi4_mem0_arcache,
            input   wire    [7:0]   s_axi4_mem0_arlen,
            input   wire    [0:0]   s_axi4_mem0_arlock,
            input   wire    [2:0]   s_axi4_mem0_arprot,
            input   wire    [3:0]   s_axi4_mem0_arqos,
            input   wire    [2:0]   s_axi4_mem0_arsize,
            input   wire            s_axi4_mem0_arvalid,
            output  wire            s_axi4_mem0_arready,
            output  wire    [5:0]   s_axi4_mem0_rid,
            output  wire    [1:0]   s_axi4_mem0_rresp,
            output  wire    [127:0] s_axi4_mem0_rdata,
            output  wire            s_axi4_mem0_rlast,
            output  wire            s_axi4_mem0_rvalid,
            input   wire            s_axi4_mem0_rready,
            
            input   wire    [5:0]   s_axi4_mem1_awid,
            input   wire            s_axi4_mem1_awuser,
            input   wire    [48:0]  s_axi4_mem1_awaddr,
            input   wire    [1:0]   s_axi4_mem1_awburst,
            input   wire    [3:0]   s_axi4_mem1_awcache,
            input   wire    [7:0]   s_axi4_mem1_awlen,
            input   wire    [0:0]   s_axi4_mem1_awlock,
            input   wire    [2:0]   s_axi4_mem1_awprot,
            input   wire    [3:0]   s_axi4_mem1_awqos,
            input   wire    [2:0]   s_axi4_mem1_awsize,
            input   wire            s_axi4_mem1_awvalid,
            output  wire            s_axi4_mem1_awready,
            input   wire    [127:0] s_axi4_mem1_wdata,
            input   wire    [15:0]  s_axi4_mem1_wstrb,
            input   wire            s_axi4_mem1_wlast,
            input   wire            s_axi4_mem1_wvalid,
            output  wire            s_axi4_mem1_wready,
            output  wire    [5:0]   s_axi4_mem1_bid,
            output  wire    [1:0]   s_axi4_mem1_bresp,
            output  wire            s_axi4_mem1_bvalid,
            input   wire            s_axi4_mem1_bready,
            input   wire    [5:0]   s_axi4_mem1_arid,
            input   wire            s_axi4_mem1_aruser,
            input   wire    [48:0]  s_axi4_mem1_araddr,
            input   wire    [1:0]   s_axi4_mem1_arburst,
            input   wire    [3:0]   s_axi4_mem1_arcache,
            input   wire    [7:0]   s_axi4_mem1_arlen,
            input   wire    [0:0]   s_axi4_mem1_arlock,
            input   wire    [2:0]   s_axi4_mem1_arprot,
            input   wire    [3:0]   s_axi4_mem1_arqos,
            input   wire    [2:0]   s_axi4_mem1_arsize,
            input   wire            s_axi4_mem1_arvalid,
            output  wire            s_axi4_mem1_arready,
            output  wire    [5:0]   s_axi4_mem1_rid,
            output  wire    [1:0]   s_axi4_mem1_rresp,
            output  wire    [127:0] s_axi4_mem1_rdata,
            output  wire            s_axi4_mem1_rlast,
            output  wire            s_axi4_mem1_rvalid,
            input   wire            s_axi4_mem1_rready
        );
    
    localparam RATE100 = 1000.0/100.00;
    
    reg         reset = 1;
    initial #100 reset = 0;
    
    reg         clk100 = 1'b1;
    always #(RATE100/2.0) clk100 <= ~clk100;
    
    assign out_resetn = ~reset;
    assign out_clk    = clk100;
    
    jelly_axi4_slave_model
            #(
                .AXI_ID_WIDTH           (6),
                .AXI_ADDR_WIDTH         (49),
                .AXI_DATA_SIZE          (4),
                .MEM_WIDTH              (17),
                
                .WRITE_LOG_FILE         ("axi4_mem0_write.txt"),
                .READ_LOG_FILE          ("axi4_mem0_read.txt"),
                
                .AW_DELAY               (20),
                .AR_DELAY               (20),
                
                .AW_FIFO_PTR_WIDTH      (4),
                .W_FIFO_PTR_WIDTH       (4),
                .B_FIFO_PTR_WIDTH       (4),
                .AR_FIFO_PTR_WIDTH      (4),
                .R_FIFO_PTR_WIDTH       (4),
                
                .AW_BUSY_RATE           (0),
                .W_BUSY_RATE            (0),
                .B_BUSY_RATE            (0),
                .AR_BUSY_RATE           (0),
                .R_BUSY_RATE            (0)
            )
        i_axi4_slave_model_0
            (
                .aresetn                (~reset),
                .aclk                   (clk100),
                
                .s_axi4_awid            (s_axi4_mem0_awid),
                .s_axi4_awaddr          (s_axi4_mem0_awaddr),
                .s_axi4_awlen           (s_axi4_mem0_awlen),
                .s_axi4_awsize          (s_axi4_mem0_awsize),
                .s_axi4_awburst         (s_axi4_mem0_awburst),
                .s_axi4_awlock          (s_axi4_mem0_awlock),
                .s_axi4_awcache         (s_axi4_mem0_awcache),
                .s_axi4_awprot          (s_axi4_mem0_awprot),
                .s_axi4_awqos           (s_axi4_mem0_awqos),
                .s_axi4_awvalid         (s_axi4_mem0_awvalid),
                .s_axi4_awready         (s_axi4_mem0_awready),
                .s_axi4_wdata           (s_axi4_mem0_wdata),
                .s_axi4_wstrb           (s_axi4_mem0_wstrb),
                .s_axi4_wlast           (s_axi4_mem0_wlast),
                .s_axi4_wvalid          (s_axi4_mem0_wvalid),
                .s_axi4_wready          (s_axi4_mem0_wready),
                .s_axi4_bid             (s_axi4_mem0_bid),
                .s_axi4_bresp           (s_axi4_mem0_bresp),
                .s_axi4_bvalid          (s_axi4_mem0_bvalid),
                .s_axi4_bready          (s_axi4_mem0_bready),
                .s_axi4_arid            (s_axi4_mem0_arid),
                .s_axi4_araddr          (s_axi4_mem0_araddr),
                .s_axi4_arlen           (s_axi4_mem0_arlen),
                .s_axi4_arsize          (s_axi4_mem0_arsize),
                .s_axi4_arburst         (s_axi4_mem0_arburst),
                .s_axi4_arlock          (s_axi4_mem0_arlock),
                .s_axi4_arcache         (s_axi4_mem0_arcache),
                .s_axi4_arprot          (s_axi4_mem0_arprot),
                .s_axi4_arqos           (s_axi4_mem0_arqos),
                .s_axi4_arvalid         (s_axi4_mem0_arvalid),
                .s_axi4_arready         (s_axi4_mem0_arready),
                .s_axi4_rid             (s_axi4_mem0_rid),
                .s_axi4_rdata           (s_axi4_mem0_rdata),
                .s_axi4_rresp           (s_axi4_mem0_rresp),
                .s_axi4_rlast           (s_axi4_mem0_rlast),
                .s_axi4_rvalid          (s_axi4_mem0_rvalid),
                .s_axi4_rready          (s_axi4_mem0_rready)
            );
    
        jelly_axi4_slave_model
            #(
                .AXI_ID_WIDTH           (6),
                .AXI_ADDR_WIDTH         (49),
                .AXI_DATA_SIZE          (4),
                .MEM_WIDTH              (17),
                
                .WRITE_LOG_FILE         ("axi4_mem1_write.txt"),
                .READ_LOG_FILE          ("axi4_mem1_read.txt"),
                
                .AW_DELAY               (20),
                .AR_DELAY               (20),
                
                .AW_FIFO_PTR_WIDTH      (4),
                .W_FIFO_PTR_WIDTH       (4),
                .B_FIFO_PTR_WIDTH       (4),
                .AR_FIFO_PTR_WIDTH      (4),
                .R_FIFO_PTR_WIDTH       (4),
                
                .AW_BUSY_RATE           (0),
                .W_BUSY_RATE            (0),
                .B_BUSY_RATE            (0),
                .AR_BUSY_RATE           (0),
                .R_BUSY_RATE            (0)
            )
        i_axi4_slave_model_1
            (
                .aresetn                (~reset),
                .aclk                   (clk100),
                
                .s_axi4_awid            (s_axi4_mem1_awid),
                .s_axi4_awaddr          (s_axi4_mem1_awaddr),
                .s_axi4_awlen           (s_axi4_mem1_awlen),
                .s_axi4_awsize          (s_axi4_mem1_awsize),
                .s_axi4_awburst         (s_axi4_mem1_awburst),
                .s_axi4_awlock          (s_axi4_mem1_awlock),
                .s_axi4_awcache         (s_axi4_mem1_awcache),
                .s_axi4_awprot          (s_axi4_mem1_awprot),
                .s_axi4_awqos           (s_axi4_mem1_awqos),
                .s_axi4_awvalid         (s_axi4_mem1_awvalid),
                .s_axi4_awready         (s_axi4_mem1_awready),
                .s_axi4_wdata           (s_axi4_mem1_wdata),
                .s_axi4_wstrb           (s_axi4_mem1_wstrb),
                .s_axi4_wlast           (s_axi4_mem1_wlast),
                .s_axi4_wvalid          (s_axi4_mem1_wvalid),
                .s_axi4_wready          (s_axi4_mem1_wready),
                .s_axi4_bid             (s_axi4_mem1_bid),
                .s_axi4_bresp           (s_axi4_mem1_bresp),
                .s_axi4_bvalid          (s_axi4_mem1_bvalid),
                .s_axi4_bready          (s_axi4_mem1_bready),
                .s_axi4_arid            (s_axi4_mem1_arid),
                .s_axi4_araddr          (s_axi4_mem1_araddr),
                .s_axi4_arlen           (s_axi4_mem1_arlen),
                .s_axi4_arsize          (s_axi4_mem1_arsize),
                .s_axi4_arburst         (s_axi4_mem1_arburst),
                .s_axi4_arlock          (s_axi4_mem1_arlock),
                .s_axi4_arcache         (s_axi4_mem1_arcache),
                .s_axi4_arprot          (s_axi4_mem1_arprot),
                .s_axi4_arqos           (s_axi4_mem1_arqos),
                .s_axi4_arvalid         (s_axi4_mem1_arvalid),
                .s_axi4_arready         (s_axi4_mem1_arready),
                .s_axi4_rid             (s_axi4_mem1_rid),
                .s_axi4_rdata           (s_axi4_mem1_rdata),
                .s_axi4_rresp           (s_axi4_mem1_rresp),
                .s_axi4_rlast           (s_axi4_mem1_rlast),
                .s_axi4_rvalid          (s_axi4_mem1_rvalid),
                .s_axi4_rready          (s_axi4_mem1_rready)
            );
    
endmodule

