module vga_top#(
    parameter H_DISPLAY = 300,
    parameter V_DISPLAY = 200,
    parameter init_fb  = "",
    parameter init_pal = ""
)(
    input wire clk,          // 25 MHz
    input wire rst,

    output wire video_on_o,
    output wire [9:0] x_o,
    output wire [9:0] y_o,
    output wire pixel_tick_o,
    output wire hsync_o,
    output wire vsync_o,
    output wire [11:0] rgb, 

    // Wishbone VGA framebuffer bus
    input  wire [31:0]  wb_fb_adr_i,
    input  wire [31:0]  wb_fb_dat_i,
    input  wire [3:0]   wb_fb_sel_i,
    input  wire         wb_fb_we_i,
    input  wire         wb_fb_cyc_i,
    input  wire         wb_fb_stb_i,
    input  wire [2:0]   wb_fb_cti_i,
    input  wire [1:0]   wb_fb_bte_i,
    output wire [31:0]   wb_fb_dat_o,
    output wire          wb_fb_ack_o,
    output wire          wb_fb_err_o,
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
    output wire [31:0]   wb_pal_dat_o,
    output wire          wb_pal_ack_o,
    output wire          wb_pal_err_o,
    output reg          wb_pal_rty_o,

    // Wishbone VGA CTRL
    input  wire [31:0]  wb_ctrl_adr_i,
    input  wire [31:0]  wb_ctrl_dat_i,
    input  wire [3:0]   wb_ctrl_sel_i,
    input  wire         wb_ctrl_we_i,
    input  wire         wb_ctrl_cyc_i,
    input  wire         wb_ctrl_stb_i,
    input  wire [2:0]   wb_ctrl_cti_i,
    input  wire [1:0]   wb_ctrl_bte_i,
    output wire [31:0]  wb_ctrl_dat_o,
    output wire         wb_ctrl_ack_o,
    output wire         wb_ctrl_err_o,
    output wire         wb_ctrl_rty_o
);

    /* ------------------------- TIMING -------------------------- */ 
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

    /* ------------------- WISHBONE FRAMEBUFFER -------------------- */ 
    localparam FRAMEBUFFER_SIZE_BYTES = H_DISPLAY * V_DISPLAY; // 64000 bytes
    localparam FRAMEBUFFER_ADR_SIZE = $clog2(FRAMEBUFFER_SIZE_BYTES);
    wire fb_rd;
    wire [31:0] fb_rd_addr;
    wire [31:0] fb_data;

    // Addressing notes:
    // ...  
    // Check this one out! Might give problems with higher addresses.. 
    // Bit size might be wrong.
    wb_ram #(
        .dw(32),
        .depth(FRAMEBUFFER_SIZE_BYTES),
        .memfile(init_fb)
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
        .wb_dat_o(wb_fb_dat_o),
        .clk_vga        (clk),
        .i_vga_rd       (fb_rd),
        .i_vga_rd_addr  (fb_rd_addr),
        .vga_data_o     (fb_data)
    );

    /* ---------------------- WISHBONE PALETTE -------------------------- */ 
    localparam PALETTE_ENTRIES = 256;
    localparam PALETTE_SIZE_BYTES = PALETTE_ENTRIES*4;
    localparam PALETTE_ADR_SIZE = $clog2(PALETTE_SIZE_BYTES);
    wire pal_rd;
    wire [31:0] pal_rd_addr;
    wire [31:0] pal_data;

    wb_ram #(
        .dw(32),
        .depth(PALETTE_SIZE_BYTES),
        .memfile(init_pal)
    ) wb_ram_pal (
        .wb_clk_i       (clk),
        .wb_rst_i       (rst),
        .wb_adr_i       (wb_pal_adr_i[PALETTE_ADR_SIZE-1:0]),
        .wb_dat_i       (wb_pal_dat_i),
        .wb_sel_i       (wb_pal_sel_i),
        .wb_we_i        (wb_pal_we_i),
        .wb_bte_i       (wb_pal_bte_i),
        .wb_cti_i       (wb_pal_cti_i),
        .wb_cyc_i       (wb_pal_cyc_i),
        .wb_stb_i       (wb_pal_stb_i),
        .wb_ack_o       (wb_pal_ack_o),
        .wb_err_o       (wb_pal_err_o),
        .wb_dat_o       (wb_pal_dat_o),
        .clk_vga        (clk),
        //.i_vga_rd       (pal_rd),
        .i_vga_rd       (1'b1),         // Always enabled for now...
        .i_vga_rd_addr  (pal_rd_addr),
        .vga_data_o     (pal_data)
    );

    /* ---------------------- PIXEL CONTROL UNIT -------------------- */ 
    vga_pcu #(
        .COORD_SIZE(10)
    ) vga_pcu_i (
        .clk            (clk),
        .rst            (rst),
        .video_on       (video_on_o),
        .x              (x_o),
        .y              (y_o),
        .fb_data_i      (fb_data),
        .fb_addr_o      (fb_rd_addr),
        .fb_rd_o        (fb_rd),
        .pal_rd_data_i  (pal_data),
        .pal_rd_addr_o  (pal_rd_addr),
        // .pal_rd_o       (pal_rd),
        .rgb444         (rgb),

        // Wishbone CTRL
        .wb_adr_i  (wb_ctrl_adr_i),
        .wb_dat_i  (wb_ctrl_dat_i),
        .wb_sel_i  (wb_ctrl_sel_i),
        .wb_we_i   (wb_ctrl_we_i),
        .wb_cyc_i  (wb_ctrl_cyc_i),
        .wb_stb_i  (wb_ctrl_stb_i),
        .wb_cti_i  (wb_ctrl_cti_i),
        .wb_bte_i  (wb_ctrl_bte_i),
        .wb_dat_o  (wb_ctrl_dat_o),
        .wb_ack_o  (wb_ctrl_ack_o),
        .wb_err_o  (wb_ctrl_err_O),
        .wb_rty_o  (wb_ctrl_rty_o)
    );

    // If rtry not used
    always @(posedge clk) begin
        wb_fb_rty_o     <= 1'b0;    
        wb_pal_rty_o    <= 1'b0;
    end

endmodule
