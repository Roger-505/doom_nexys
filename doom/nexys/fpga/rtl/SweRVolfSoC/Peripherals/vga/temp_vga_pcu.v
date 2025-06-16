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

    localparam H_DISPLAY = 640;
    localparam V_DISPLAY = 480;
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

	reg [3:0] pp_yscale_state;

	always @(posedge clk)
		if (is_first_h_line) begin
			if (is_first_v_line) begin
				pp_yscale_state <= 4'h0;
				double_y <= 1'b0;
			end else begin
				case (pp_yscale_state)
					4'h0:    { double_y, pp_yscale_state } <= { 1'b1, 4'h1 };
					4'h1:    { double_y, pp_yscale_state } <= { 1'b0, 4'h2 };
					4'h2:    { double_y, pp_yscale_state } <= { 1'b1, 4'h3 };
					4'h3:    { double_y, pp_yscale_state } <= { 1'b0, 4'h4 };
					4'h4:    { double_y, pp_yscale_state } <= { 1'b1, 4'h5 };
					4'h5:    { double_y, pp_yscale_state } <= { 1'b1, 4'h6 };
					4'h6:    { double_y, pp_yscale_state } <= { 1'b0, 4'h7 };
					4'h7:    { double_y, pp_yscale_state } <= { 1'b1, 4'h8 };
					4'h8:    { double_y, pp_yscale_state } <= { 1'b0, 4'h9 };
					4'h9:    { double_y, pp_yscale_state } <= { 1'b0, 4'ha };
					4'ha:    { double_y, pp_yscale_state } <= { 1'b1, 4'hb };
					4'hb:    { double_y, pp_yscale_state } <= { 1'b1, 4'h0 };
					default: { double_y, pp_yscale_state } <= { 1'b0, 4'h0 };
				endcase;
			end
		end

    reg video_on_ff;
	always @(posedge clk) begin
		video_on_ff <= video_on;
		double_x <= (double_x ^ 1'b1) & ~is_first_h_line;
	end

    always @(posedge clk)
        if (is_first_h_line) begin
            if (is_first_v_line)
                pixel_base_addr <= 16'b0;
            else if (double_y)
                pixel_base_addr <= pixel_base_addr;
            else
                pixel_base_addr <= pixel_base_addr + NEXT_H_LINE;
        end

    always @(posedge clk)
        if (is_first_h_line) begin
            if (is_first_v_line)
                pixel_addr <= 16'b0;
            else
                pixel_addr <= pixel_base_addr;
        end 
        else if (double_x)
            pixel_addr <= pixel_addr;
        else
            pixel_addr <= pixel_addr + 1;
    
	assign fb_addr_o  = pixel_addr[15:2];
	assign fb_rd = video_on_ff & (pixel_addr[1:0] == 2'b00) & ~double_x;
    
    reg fb_rd_ff;
    always @(posedge clk)
        fb_rd_ff <= fb_rd;

    assign fb_rd_o = fb_rd_ff;

    always @(posedge clk)
        if (double_x)
            pixel_data <= fb_rd_ff ? fb_data_i : { 8'h00, pixel_data[31:8] };

    // Get palette RGB444. pixel_data indexes palette
	assign pal_rd_addr_o = pixel_data[7:0];

	assign rgb444 = {
		pal_rd_data_i[11:8], 	// R[11: 8]
		pal_rd_data_i[7:4], 	// G[ 7: 4]
		pal_rd_data_i[3:0]   	// B[ 3: 0]
	};

    /* --- VGA registers --- */
    reg vs_in_vbl;
    reg [15:0] vs_frame_cnt;

	always @(posedge clk)
		vs_in_vbl <= (vs_in_vbl & ~is_first_v_line) | (is_last_h_line & is_last_v_line);

	always @(posedge clk)
		if (rst)
			vs_frame_cnt <= 0;
		else
			vs_frame_cnt <= vs_frame_cnt + (is_last_h_line & is_last_v_line);

    /* ---- Timing signals logic ---- */
    assign is_first_h_line = (video_on) & (x == 0);
    assign is_first_v_line = (video_on) & (y == 0);
    assign is_last_h_line = (video_on) & (x == H_DISPLAY - 1);
    assign is_last_v_line = (video_on) & (y == V_DISPLAY - 1);

endmodule
