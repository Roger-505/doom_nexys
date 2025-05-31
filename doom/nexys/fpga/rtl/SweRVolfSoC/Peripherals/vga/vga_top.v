module vga_top(
    input clk,          // 25 MHz
    input rst,

    output video_on_o,
    output [9:0] x_o,
    output [9:0] y_o,
    output pixel_tick_o,
    output hsync_o,
    output vsync_o
);

    // VGA 640x480 @60Hz timing parameters (25MHz pixel clock)
    parameter H_DISPLAY  = 640;
    parameter HF_PORCH   = 48;
    parameter H_RETRACE  = 96;
    parameter HB_PORCH   = 16;
    parameter H_MAX      = H_DISPLAY + HF_PORCH + H_RETRACE + HB_PORCH - 1;

    parameter V_DISPLAY  = 480;
    parameter VF_PORCH   = 10;
    parameter V_RETRACE  = 2;
    parameter VB_PORCH   = 33;
    parameter V_MAX      = V_DISPLAY + VF_PORCH + V_RETRACE + VB_PORCH - 1;

    // Registers
    reg [9:0] hcount_reg, vcount_reg;
    wire [9:0] hcount_next, vcount_next;
    reg hsync_reg, vsync_reg;
    wire hsync_next, vsync_next;

    // Horizontal counter
    assign hcount_next = (hcount_reg == H_MAX) ? 0 : hcount_reg + 1;

    // Vertical counter
    assign vcount_next = (hcount_reg == H_MAX) ?
                         ((vcount_reg == V_MAX) ? 0 : vcount_reg + 1) :
                         vcount_reg;

    // Sync pulse generation (active low)
    assign hsync_next = ~((hcount_reg >= (H_DISPLAY + HB_PORCH)) &&
                          (hcount_reg <  (H_DISPLAY + HB_PORCH + H_RETRACE)));

    assign vsync_next = ~((vcount_reg >= (V_DISPLAY + VB_PORCH)) &&
                          (vcount_reg <  (V_DISPLAY + VB_PORCH + V_RETRACE)));

    // Register updates
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            hcount_reg <= 0;
            vcount_reg <= 0;
            hsync_reg  <= 1'b1;
            vsync_reg  <= 1'b1;
        end else begin
            hcount_reg <= hcount_next;
            vcount_reg <= vcount_next;
            hsync_reg  <= hsync_next;
            vsync_reg  <= vsync_next;
        end
    end

    // Outputs
    assign video_on_o = (hcount_reg < H_DISPLAY) && (vcount_reg < V_DISPLAY);
    assign x_o = hcount_reg;
    assign y_o = vcount_reg;
    assign hsync_o = hsync_reg;
    assign vsync_o = vsync_reg;
    assign pixel_tick_o = clk;

endmodule
