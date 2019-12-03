`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/26 17:43:14
// Design Name: 
// Module Name: Arbiter
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
//`include "struct_list.vh"
`include "user_defines.sv"

    /*---STRUCT---*/
    typedef struct packed{
        logic [1:0]     id;
        logic [28:0]    addr;
        logic [7:0]     len;
        logic [2:0]     size;
        logic [1:0]     burst;
        logic           lock;
        logic [3:0]     cache;
        logic [2:0]     prot;
        logic [3:0]     qos;
        logic           valid;    
    }AXI_AW;
    
    typedef struct packed{
        logic [31:0]    data;
        logic [3:0]     strb;
        logic           last;
        logic           valid;  
    }AXI_W;
    
    typedef struct packed{
        logic [1:0]     id;
        logic [28:0]    addr;
        logic [7:0]     len;
        logic [2:0]     size;
        logic [1:0]     burst;
        logic           lock;
        logic [3:0]     cache;
        logic [2:0]     prot;
        logic [3:0]     qos;
        logic           valid;    
    }AXI_AR;
    
    typedef struct packed{
        logic [31:0]    data;
        logic [3:0]     strb;
        logic           last;
        logic           valid;
        logic [1:0]     resp;
    }AXI_R;        
    
module Arbiter(
    input [7:0]           gmii_rxd,
    input                 gmii_rxctl,
    input                 eth_rxck,
    input                 rst_rx,
    input                 start_udp_i,
    input [3:0]           host_i,
    input [3:0]           dst_i,
    input [3:0]           packet_i,
    
    //AXI0
    input                 axi_awready,
    input                 axi_wready,
    input                 axi_bresp,
    input                 axi_bvalid,
    input                 axi_arready,
    input AXI_R           axi_r,
    
    output [8:0]          rarp_o,
    output [8:0]          ping_o,
    output [8:0]          UDP_o,
    //AXI0
    output AXI_AW         axi_aw,
    output AXI_W          axi_w,
    output                axi_bready,
    output AXI_AR         axi_ar,
    output                axi_rready
    );
    
    assign rarp_o = 9'b0;
    assign ping_o = 9'b0;
    
    wire [47:0] my_MACadd = `my_MAC | {44'b0, host_i[3:0]};   // 2019.1.9
    wire [31:0] my_IPadd  = `my_IP  | {28'b0, host_i[3:0]};
    wire [47:0] DstMAC = (dst_i==4'b0) ? `dst_MAC : (`my_MAC | {44'b0, dst_i});
    wire [31:0] DstIP = (dst_i==4'b0) ? `dst_IP : (`my_IP  | {28'b0, dst_i});
    wire [15:0] Port = 16'd5000;
    
    trans_image trans_image(
        /*---Input---*/
        .eth_rxck       (eth_rxck),
        .rst_rx         (rst_rx),
        .start_udp      (start_udp_i),
        .my_MACadd_i    (my_MACadd),
        .my_IPadd_i     (my_IPadd),
        .DstMAC_i       (DstMAC),
        .DstIP_i        (DstIP),
        .SrcPort_i      (Port),
        .DstPort_i      (Port),
        .packet         (packet_i),        // add 2018.12.5
        .axi_arready    (axi_arready),
        .axi_r          (axi_r),
        /*---Output---*/
        .UDP_o          (UDP_o),
        .axi_ar         (axi_ar),
        .axi_rready     (axi_rready)
    );
         
endmodule
