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
    output wire         pal_rd_o,
    output wire [11:0]  rgb444
);

    localparam NEXT_H_LINE = 16'd320;

    /* ------ Timing signals -------- */
    wire is_first_h_line;
    wire is_first_v_line;
    reg is_first_h_line_r;
    reg is_first_v_line_r;
    reg  h_first;
    reg  v_first;

    /* --- Framebuffer signals --- */
    wire next_fb_rd;
    reg fb_rd;
    reg [15:0]  pixel_base_addr;
    reg [15:0]  pixel_addr;

    /* --- Palette signals --- */
    reg [31:0] pal_r_addr;
    reg pal_rd;

    /* --- Pixel doubling signals --- */
    reg         double_x;
    reg         double_y;
    reg         double_active;
	reg [3:0]   double_coord_state;
    
    /* ---- Pixel doubling logic ---- */
    
    // 2.4 Y pixel increase ratio
	always @(posedge clk)
		if (is_first_h_line) begin
			if (is_first_v_line) begin
				double_coord_state <= 4'h0;
				double_y           <= 1'b0;
			end else begin
				case (double_coord_state)
					4'h0:    { double_y, double_coord_state } <= { 1'b1, 4'h1 };
					4'h1:    { double_y, double_coord_state } <= { 1'b0, 4'h2 };
					4'h2:    { double_y, double_coord_state } <= { 1'b1, 4'h3 };
					4'h3:    { double_y, double_coord_state } <= { 1'b0, 4'h4 };
					4'h4:    { double_y, double_coord_state } <= { 1'b0, 4'h5 };
					4'h5:    { double_y, double_coord_state } <= { 1'b1, 4'h6 };
					4'h6:    { double_y, double_coord_state } <= { 1'b0, 4'h7 };
					4'h7:    { double_y, double_coord_state } <= { 1'b1, 4'h8 };
					4'h8:    { double_y, double_coord_state } <= { 1'b0, 4'h9 };
					4'h9:    { double_y, double_coord_state } <= { 1'b0, 4'ha };
					4'ha:    { double_y, double_coord_state } <= { 1'b1, 4'hb };
					4'hb:    { double_y, double_coord_state } <= { 1'b0, 4'h0 };
					default: { double_y, double_coord_state } <= { 1'b0, 4'h0 };
				endcase
			end
		end

    // Double X pixels
	always @(posedge clk) begin
		double_active <= video_on;
		double_x <= (double_x ^ 1'b1) & ~is_first_h_line;
	end

    // Base address modified according Y pixel doubling
	always @(posedge clk)
		if (is_first_h_line) begin
			if (is_first_v_line)
				pixel_base_addr <= 0;
			else
				pixel_base_addr <= pixel_base_addr + (double_y ? NEXT_H_LINE : 16'd0);
		end

    // Current address modified according X pixel doubling
	always @(posedge clk)
		if (is_first_h_line)
			pixel_addr <= is_first_v_line ? 16'd0 : pixel_base_addr;
		else
			pixel_addr <= pixel_addr + double_x;

    // Frame Buffer addresing 
	assign fb_addr_o  = pixel_addr[15:2];
    assign fb_rd_o    = fb_rd;
	assign next_fb_rd = double_active & (pixel_addr[1:0] == 2'b00) & ~double_x;

    // Shift out each frame buffer byte to access palette
	always @(posedge clk)
		fb_rd <= next_fb_rd;

	always @(posedge clk)
        if (double_x) begin
			pal_r_addr <= fb_rd ? fb_data_i : { 8'h00, pal_r_addr[31:8] };
            pal_rd <= 1;
        end else begin
            pal_rd <= 0;
            pal_r_addr <= fb_data_i;
        end

    assign pal_rd_o = pal_rd;

    // Get palette RGB444
	assign pal_rd_addr_o = pal_r_addr[7:0];
	assign rgb444 = {
		pal_rd_data_i[15:12], 	// R[15:11]
		pal_rd_data_i[10: 7], 	// G[10: 5]
		pal_rd_data_i[4:1]   	// B[ 4: 0]
	};


    /* ---- Timing signals logic ---- */
    // First horizontal line
    always @(posedge clk or posedge rst)
        if (!rst)
            h_first <= 1'b1;
        else 
            h_first <= x[COORD_SIZE-1];

    // First vertical line
    always @(posedge clk or posedge rst)
        if (!rst)
            v_first <= 1'b1;
        else 
            v_first <= y[COORD_SIZE-1];

    // Only consider the video active regions
    always @(posedge clk or posedge rst)
        if (!rst) begin
            is_first_h_line_r <= 1'b0;
            is_first_v_line_r <= 1'b0;
        end else begin
            is_first_h_line_r <= (video_on) & h_first;
            is_first_v_line_r <= (video_on) & v_first;
        end

    assign is_first_h_line = is_first_h_line_r;
    assign is_first_v_line = is_first_v_line_r;

endmodule
