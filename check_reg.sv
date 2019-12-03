module check_reg # (
    parameter integer DATA_WIDTH    = 32
)
(
    input   s_aclk,
    input   m_aclk,
    input [DATA_WIDTH-1:0] data,
    input   wren,

    output start_udp_o,
    output [3:0] host,
    output [3:0] dst,
    output [3:0] packet
);

    // signal
    reg [3:0] d_wren;
    
    always_ff @(posedge s_aclk)begin
        d_wren <= {d_wren[2:0],wren};
    end
    
    wire rd_en = d_wren[3];
    wire [DATA_WIDTH-1:0] dout;
    wire valid;
    // FIFO
    fifo_S2M fifo0(
        .rst(),
        .wr_clk(s_aclk),
        .rd_clk(m_aclk),
        .din(data),
        .wr_en(wren),
        .rd_en(rd_en),
        .dout(dout),
        .full(),
        .empty(),
        .valid(valid),
        .wr_rst_busy(),
        .rd_rst_busy()
    );

    // check register
    // start UDP or not
    reg start_udp;
    always_ff @(posedge m_aclk)begin
        if(dout[0])begin
            start_udp <= 1'b1;
        end
        else begin
            start_udp <= 1'b0;
        end
    end

    assign start_udp_o = start_udp;
    assign host = dout[4:1];
    assign dst = dout[8:5];
    assign packet = dout[12:9];

endmodule