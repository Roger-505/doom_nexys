module vga_fb #(
    parameter WIDTH=11,
    parameter DEPTH=640*480
)(
    input wire                      i_wclk,
    input wire                      i_wr,
    input wire [$clog2(DEPTH)-1:0]  i_wr_addr,
    input wire                      i_rclk
    input wire [$clog2(DEPTH)-1:0]  i_rd_addr,
    input wire                      i_bram_en,
    input wire [WIDTH-1:0]          i_bram_data,
    output reg [WIDTH-1:0]          o_bram_data
)
    reg [WIDTH-1:0] ram [0:DEPTH-1];

    always @(posedge i_wclk)
        if(i_bram_en && i_wr)
            ram[i_wr_addr] <= i_bram_data;

    always @(posedge i_rclk)
        if (i_rd)
            o_bram_data <= ram[i_rd_addr];
endmodule
