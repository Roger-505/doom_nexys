module vga_pcu#(
    parameter COORD_SIZE = 10
)(
    input wire clk,
    input wire rst,

    // Timing generator
    input wire  video_on,
    input wire  [COORD_SIZE-1:0]  x,
    input wire  [COORD_SIZE-1:0]  y,
 
    // Framebuffer 
    input  wire [31:0]  fb_data_i,   
    output wire [15:0]  fb_addr_o,
    output wire         fb_rd_o,

    // Palette
    input  wire [31:0]  pal_rd_data_i,
    output wire [31:0]  pal_rd_addr_o,
    // output wire         pal_rd_o,

    // RGB output
    output wire [11:0]  rgb444
);

    localparam NEXT_H_LINE = 16'd320;

    /* ------ Timing signals -------- */
    wire is_first_h_line;
    wire is_first_v_line;

    /* --- Framebuffer signals --- */
    // wire next_fb_rd;
    wire fb_rd;
    reg [15:0]  pixel_base_addr;
    reg [15:0]  pixel_addr;
    reg [31:0]  pixel_data;


    /* --- Palette signals --- */
    reg [31:0] pal_r_addr;
    reg pal_rd;

    /* --- Pixel doubling signals --- */
    reg         double_x;
    reg         double_y;
    reg         double_active;
	reg [3:0]   double_coord_state;
    
    /* ---- Pixel logic ---- */

    /*
    // FF for video_on
    reg video_on_ff;
    always @(posedge clk)
        video_on_ff <= video_on;
    */ 

    // Current address modified according X pixel doubling
    // TODO: Poner resets...
    /*
	always @(posedge clk)
		if (is_first_h_line & is_first_v_line)
            pixel_addr <=  16'd0; // is_first_v_line ? 16'd0 : pixel_base_addr;
		else
			pixel_addr <= pixel_addr + 1;
    */ 

    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;
    parameter DOOM_WIDTH    = 320;
    parameter DOOM_HEIGHT   = 200;

    // Count of visible pixels in a DOOM row
    wire is_visible_x = (x < DOOM_WIDTH);
    wire is_visible_y = (y < DOOM_HEIGHT);

    // Advance only within DOOM-visible area
    always @(posedge clk) begin
        if (is_first_h_line & is_first_v_line)
            pixel_addr <= 16'd0;
        else if (video_on & is_visible_x & is_visible_y) 
            pixel_addr <= pixel_addr + 1;
    end

    // Frame Buffer addresing 
	assign fb_addr_o  = pixel_addr[15:2];
    assign fb_rd_o    = fb_rd;

    /*
	assign fb_rd = video_on_ff & (pixel_addr[1:0] == 2'b00);
    */

	assign fb_rd = video_on & (pixel_addr[1:0] == 2'b00);

    /* 
    // Shift out each frame buffer byte to access palette
	always @(posedge clk)
		fb_rd <= next_fb_rd;
    */ 

    always @(posedge clk)
        pixel_data <= fb_rd ? fb_data_i : { 8'h00, pixel_data[31:8] };

    // Get palette RGB444. pixel_data indexes palette
	assign pal_rd_addr_o = pixel_data[7:0];
	assign rgb444 = (is_visible_x & is_visible_y) ? {
		pal_rd_data_i[11:8], 	// R[11: 8]
		pal_rd_data_i[7:4], 	// G[ 7: 4]
		pal_rd_data_i[3:0]   	// B[ 3: 0]
	} : 12'b0;

    /* ---- Timing signals logic ---- */
    assign is_first_h_line = (video_on) & (y == 0);
    assign is_first_v_line = (video_on) & (x == 0);

    /* --- Timing signals logic --- */

endmodule
