module check_reg # (
    parameter integer DATA_WIDTH    = 32
)
(
    input   s_aclk,
    input   m_aclk,
    input [DATA_WIDTH-1:0] data,
    input   wren,

    output start_udp_o
);

    // signal
    reg s_wren;
    
    always_ff @(posedge s_aclk)begin
        s_wren <= wren;
    end

    // FIFO


    // check register
    // start UDP or not
    reg start_udp;
    always_ff @(posedge m_aclk)begin
        if(1)begin
            start_udp <= 1'b1;
        end
        else begin
            start_udp <= 1'b0;
        end
    end

    assign start_udp_o = start_udp;

endmodule