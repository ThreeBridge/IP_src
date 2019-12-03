`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/31 19:16:30
// Design Name: 
// Module Name: ARP_reply
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "user_defines.sv"
module TOP(
    input           locked,

    /* Ethernet */
    input           ETH_CLK,
    input [7:0]     ETH_RXD,     // 受信フレームデータ
    input           ETH_RXCTL,   // 受信フレーム検知で'1'
    
    output [7:0]    ETH_TXD,    //-- Ether RGMII Tx data.
    output          ETH_TXCTL,
    input           start_udp_i,
    input [3:0]     host_i,
    input [3:0]     dst_i,
    input [3:0]     packet_i,
    
    /* AXI */
    output [1:0]    M_AXI_AWID,
    output [28:0]   M_AXI_AWADDR,
    output [7:0]    M_AXI_AWLEN,
    output [2:0]    M_AXI_AWSIZE,
    output [1:0]    M_AXI_AWBURST,
    output          M_AXI_AWLOCK,
    output [3:0]    M_AXI_AWCACHE,
    output [2:0]    M_AXI_AWPROT,
    output [3:0]    M_AXI_AWQOS,
    output          M_AXI_AWVALID,
    input           M_AXI_AWREADY,
    output [31:0]   M_AXI_WDATA,
    output [3:0]    M_AXI_WSTRB,
    output          M_AXI_WLAST,
    output          M_AXI_WVALID,
    input           M_AXI_WREADY,
    input           M_AXI_BRESP,
    input           M_AXI_BVALID,
    output          M_AXI_BREADY,
    output [1:0]    M_AXI_ARID,
    output [28:0]   M_AXI_ARADDR,
    output [7:0]    M_AXI_ARLEN,
    output [2:0]    M_AXI_ARSIZE,
    output [1:0]    M_AXI_ARBURST,
    output          M_AXI_ARLOCK,
    output [3:0]    M_AXI_ARCACHE,
    output [2:0]    M_AXI_ARPROT,
    output [3:0]    M_AXI_ARQOS,
    output          M_AXI_ARVALID,
    input           M_AXI_ARREADY,
    input [31:0]    M_AXI_RDATA,
    input [1:0]     M_AXI_RRESP,
    input           M_AXI_RLAST,
    input           M_AXI_RVALID,
    output          M_AXI_RREADY
    );    
    
    AXI_AW          axi_aw;
    AXI_W           axi_w;
    AXI_AR          axi_ar;
    AXI_R           axi_r;
    
    wire rst_rx;
    //**------------------------------------------------------------
    //** Reset generator. (add by moikawa)
    //**
    RSTGEN rstgen (
         .reset_o  ( rst_rx ),
         .reset_i  ( 1'b0   ),
         .locked_i ( locked ),
         .clk      ( ETH_CLK )
    );
    //AXI0
    wire axi_awready;
    wire axi_wready;
    wire axi_bresp;
    wire axi_bvalid;
    wire axi_bready;
    wire axi_arready;
    wire axi_rready;
    
    wire [8:0] rarp_o;   
    wire [8:0] ping_o;  
    wire [8:0] UDP_btn_d;   // ボタン入力によるUDP送信
    wire [8:0] UDP_o;       // UDPの送受信
    
    Arbiter R_Arbiter (
        /*---INPUT---*/
        .gmii_rxd     (ETH_RXD),   //<-- "rgmii2gmii"
        .gmii_rxctl   (ETH_RXCTL), //<-- "rgmii2gmii"
        .eth_rxck     (ETH_CLK),   //<-- "eth_clkgen"
        .rst_rx       (rst_rx),
        .start_udp_i  (start_udp_i),
        .host_i       (host_i),
        .dst_i        (dst_i),
        .packet_i     (packet_i),
        //AXI0
        .axi_awready  (axi_awready),
        .axi_wready   (axi_wready),
        .axi_bresp    (axi_bresp),
        .axi_bvalid   (axi_bvalid),
        .axi_arready  (axi_arready),
        .axi_r        (axi_r),
        /*---OUTPUT---*/
        .rarp_o       (rarp_o),
        .ping_o       (ping_o),
        .UDP_o        (UDP_o),
        //AXI0
        .axi_aw       (axi_aw),
        .axi_w        (axi_w),
        .axi_bready   (axi_bready),
        .axi_ar       (axi_ar),
        .axi_rready   (axi_rready)
    );

    T_Arbiter T_Arbiter(
        /*---INPUT---*/
        .rarp_i       (rarp_o),
        .ping_i       (ping_o),
        .UDP_btn_d(UDP_btn_d),
        .UDP_i        (UDP_o),
        .eth_rxck(ETH_CLK),
        .rst       (rst_rx),
        /*---OUTPUT---*/
        .txd_o        (ETH_TXD),
        .gmii_txctl_o (ETH_TXCTL)
    );
    
    assign M_AXI_AWID = axi_aw.id;
    assign M_AXI_AWADDR = axi_aw.addr;
    assign M_AXI_AWLEN = axi_aw.len;
    assign M_AXI_AWSIZE = axi_aw.size;
    assign M_AXI_AWBURST = axi_aw.burst;
    assign M_AXI_AWLOCK = axi_aw.lock;
    assign M_AXI_AWCACHE = axi_aw.cache;
    assign M_AXI_AWPROT = axi_aw.prot;
    assign M_AXI_AWQOS = axi_aw.qos;
    assign M_AXI_AWVALID = axi_aw.valid;
    assign axi_awready = M_AXI_AWREADY;
    
    assign M_AXI_WDATA = axi_w.data;
    assign M_AXI_WSTRB = axi_w.strb;
    assign M_AXI_WLAST = axi_w.last;
    assign M_AXI_WVALID = axi_w.valid;
    assign axi_wready = M_AXI_WREADY;
    
    assign axi_bresp = M_AXI_BRESP;
    assign axi_bvalid = M_AXI_BVALID;
    assign M_AXI_BREADY = axi_bready;
    
    assign M_AXI_ARID = axi_ar.id;
    assign M_AXI_ARADDR = axi_ar.addr;
    assign M_AXI_ARLEN = axi_ar.len;
    assign M_AXI_ARSIZE = axi_ar.size;
    assign M_AXI_ARBURST = axi_ar.burst;
    assign M_AXI_ARLOCK = axi_ar.lock;
    assign M_AXI_ARCACHE = axi_ar.cache;
    assign M_AXI_ARPROT = axi_ar.prot;
    assign M_AXI_ARQOS = axi_ar.qos;
    assign M_AXI_ARVALID = axi_ar.valid;
    assign axi_arready = M_AXI_ARREADY;
    
    assign axi_r.data = M_AXI_RDATA; 
    assign axi_r.resp = M_AXI_RRESP;
    assign axi_r.last = M_AXI_RLAST;
    assign axi_r.valid = M_AXI_RVALID;
    assign M_AXI_RREADY = axi_rready;
    
endmodule
