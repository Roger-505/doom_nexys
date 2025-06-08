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

    // Wishbone VGA framebuffer bus
    input  wire [31:0]  wb_fb_adr_i,
    input  wire [31:0]  wb_fb_dat_i,
    input  wire [3:0]   wb_fb_sel_i,
    input  wire         wb_fb_we_i,
    input  wire         wb_fb_cyc_i,
    input  wire         wb_fb_stb_i,
    input  wire [2:0]   wb_fb_cti_i,
    input  wire [1:0]   wb_fb_bte_i,
    output reg [31:0]   wb_fb_dat_o,
    output reg          wb_fb_ack_o,
    output reg          wb_fb_err_o,
    output reg          wb_fb_rty_o,

    // Wishbone VGA palette bus
    input  wire [31:0]  wb_pal_adr_i,
    input  wire [31:0]  wb_pal_dat_i,
    input  wire [3:0]   wb_pal_sel_i,
    input  wire         wb_pal_we_i,
    input  wire         wb_pal_cyc_i,
    input  wire         wb_pal_stb_i,
    input  wire [2:0]   wb_pal_cti_i,
    input  wire [1:0]   wb_pal_bte_i,
    output reg [31:0]   wb_pal_dat_o,
    output reg          wb_pal_ack_o,
    output reg          wb_pal_err_o,
    output reg          wb_pal_rty_o
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

    /* ------------------- START WISHBONE FRAMEBUFFER -------------------- */ 
    localparam FRAMEBUFFER_SIZE_BYTES = H_DISPLAY * V_DISPLAY; // 64000 bytes
    localparam FRAMEBUFFER_ADR_SIZE = $clog2(FRAMEBUFFER_SIZE_BYTES);
    // Addressing notes:
    // ...  
    // Check this one out! Might give problems with higher addresses.. 
    // Bit size might be wrong.

    wb_ram #(
        .dw(32),
        .depth(FRAMEBUFFER_SIZE_BYTES),
        .memfile(memfile)
    ) wb_ram_fb (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .wb_adr_i(wb_fb_adr_i[FRAMEBUFFER_ADR_SIZE-1:0]),
        .wb_dat_i(wb_fb_dat_i),
        .wb_sel_i(wb_fb_sel_i),
        .wb_we_i (wb_fb_we_i),
        .wb_bte_i(wb_fb_bte_i),
        .wb_cti_i(wb_fb_cti_i),
        .wb_cyc_i(wb_fb_cyc_i),
        .wb_stb_i(wb_fb_stb_i),
        .wb_ack_o(wb_fb_ack_o),
        .wb_err_o(wb_fb_err_o),
        .wb_dat_o(wb_fb_dat_o)
    );

    assign wb_fb_rty_o = 1'b0;  // if retry not used

    /* ---------------------- START WISHBONE PALETTE -------------------------- */ 
    localparam PALETTE_SIZE_BYTES = 256;
    localparam PALETTE_ADR_SIZE = $clog2(PALETTE_SIZE_BYTES);

    wb_ram #(
        .dw(32),
        .depth(PALETTE_SIZE_BYTES),
        .memfile("")
    ) wb_ram_pal (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .wb_adr_i(wb_pal_adr_i[PALETTE_ADR_SIZE-1:0]),
        .wb_dat_i(wb_pal_dat_i),
        .wb_sel_i(wb_pal_sel_i),
        .wb_we_i (wb_pal_we_i),
        .wb_bte_i(wb_pal_bte_i),
        .wb_cti_i(wb_pal_cti_i),
        .wb_cyc_i(wb_pal_cyc_i),
        .wb_stb_i(wb_pal_stb_i),
        .wb_ack_o(wb_pal_ack_o),
        .wb_err_o(wb_pal_err_o),
        .wb_dat_o(wb_pal_dat_o)
    );

    assign wb_pal_rty_o = 1'b0;  // if retry not used
endmodule
