`default_nettype none

module vga_top#(
    parameter H_DISPLAY = 300,
    parameter V_DISPLAY = 200,
    parameter memfile = ""
)(
    input wire clk,          // 25 MHz
    input wire rst,

    output wire video_on_o,
    output wire [9:0] x_o,
    output wire [9:0] y_o,
    output wire pixel_tick_o,
    output wire hsync_o,
    output wire vsync_o,

    // Wishbone bus
    input  wire [31:0]  wb_adr_i,
    input  wire [31:0]  wb_dat_i,
    input  wire [3:0]   wb_sel_i,
    input  wire         wb_we_i,
    input  wire         wb_cyc_i,
    input  wire         wb_stb_i,
    input  wire [2:0]   wb_cti_i,
    input  wire [1:0]   wb_bte_i,
    output reg [31:0] wb_dat_o,
    output reg          wb_ack_o,
    output reg          wb_err_o,
    output reg          wb_rty_o
);

    /* ------------------------- START TIMING -------------------------- */ 
    vga_tg 
    vga_tg_i (
        .clk(clk),
        .rst(rst),
        .video_on_o(video_on_o),
        .x_o(x_o),
        .y_o(y_o),
        .pixel_tick_o(pixel_tick_o),
        .hsync_o(hsync_o),
        .vsync_o(vsync_o)
    );
    /* ------------------------- END TIMING ------------------------------ */ 

    /* ---------------------- START WISHBONE ----------------------------- */ 
    localparam FRAMEBUFFER_SIZE_BYTES = H_DISPLAY * V_DISPLAY; // 64000 bytes
    localparam RAM_DEPTH_WORDS = FRAMEBUFFER_SIZE_BYTES / 4;   // 16000 words
    localparam ADDR_WIDTH = $clog2(RAM_DEPTH_WORDS);           // ~17 bits (17 bits to address 76,800 words)

    wb_ram #(
        .dw(32),
        .depth(FRAMEBUFFER_SIZE_BYTES),
        .memfile(memfile)
    ) wb_ram_i (
        .wb_clk_i(clk),
        .wb_rst_i(rst),

        // Addressing notes:
        // wb_adr_i is byte address from CPU (32 bits)
        // RAM word address = wb_adr_i[ADDR_WIDTH+1:2]
        // - bits [1:0] = byte offset inside word
        // - bits [ADDR_WIDTH+1:2] = word index
        // So for ADDR_WIDTH=17, use bits [18:2]

        .wb_adr_i(wb_adr_i[ADDR_WIDTH+1:2]),

        .wb_dat_i(wb_dat_i),
        .wb_sel_i(wb_sel_i),
        .wb_we_i(wb_we_i),
        .wb_bte_i(wb_bte_i),
        .wb_cti_i(wb_cti_i),
        .wb_cyc_i(wb_cyc_i),
        .wb_stb_i(wb_stb_i),

        .wb_ack_o(wb_ack_o),
        .wb_err_o(wb_err_o),
        .wb_dat_o(wb_dat_o)
    );

    assign wb_rty_o = 1'b0;  // if retry not used
    /* ---------------------- END WISHBONE ------------------------------- */ 
endmodule
