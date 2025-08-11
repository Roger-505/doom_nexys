module ps2_wb_fifo_wrapper(
    input  wire        clk,
    input  wire        resetn,

    // Wishbone
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    input  wire        wb_we_i,
    input  wire [1:0]  wb_sel_i,
    input  wire [31:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    output reg  [31:0] wb_dat_o,
    output reg         wb_ack_o,
    output reg         wb_err_o,
    output reg         wb_rty_o,

    // PS2 signals
    inout wire        ps2_clk,
    inout wire        ps2_data
);

    // Opencores PS2 module
    parameter TRUE=1;
    parameter DISABLE_SHIFT=TRUE;

    // Receive signals
    wire        rx_extended;
    wire        rx_released;
    wire        rx_shift_key_on;
    wire [7:0]  rx_scan_code;
    wire [7:0]  rx_ascii;
    wire        rx_data_ready;
    reg         rx_read;

    // Transmit signals
    reg  [7:0]  tx_data;
    reg         tx_write;
    wire        tx_write_ack_o;
    wire        tx_error_no_keyboard_ack;

    ps2_keyboard_interface #(
      .TIMER_60USEC_VALUE_PP(3000),  // 60µs at 50 MHz
      .TIMER_60USEC_BITS_PP(12),     // ceil(log2(3000))
      .TIMER_5USEC_VALUE_PP(250),    // 5µs at 50 MHz
      .TIMER_5USEC_BITS_PP(8),       // ceil(log2(250))
      .TRAP_SHIFT_KEYS_PP(DISABLE_SHIFT)
    ) ps2_inst (
      .clk(clk),
      .reset(~resetn),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .rx_extended(rx_extended),
      .rx_released(rx_released),
      .rx_shift_key_on(rx_shift_key_on),
      .rx_scan_code(rx_scan_code),
      .rx_ascii(rx_ascii),
      .rx_data_ready(rx_data_ready),
      .rx_read(rx_read),
      .tx_data(tx_data),
      .tx_write(tx_write),
      .tx_write_ack_o(tx_write_ack_o),
      .tx_error_no_keyboard_ack(tx_error_no_keyboard_ack)
    );

    // FIFO
    parameter FIFO_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter FIFO_ADDR_SIZE = $clog2(FIFO_DEPTH);

    reg  [FIFO_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
    reg  [FIFO_ADDR_SIZE-1:0] wr_ptr = 0;
    reg  [FIFO_ADDR_SIZE-1:0] rd_ptr = 0;
    reg  [FIFO_ADDR_SIZE+1:0] count  = 0; // up to 16. +1 to account for all fifo entries

    wire fifo_full  = (count == FIFO_DEPTH);
    wire fifo_empty = (count == 0);
    wire [FIFO_WIDTH-1:0] fifo_out = fifo[rd_ptr];

    // Edge detection of rx_released, it's level based
    reg rx_released_prev, rx_released_rising;
    wire rx_released_rising; 
    assign rx_released_rising = rx_released && !rx_released_prev;

    // Wishbone + FIFO
    always @(posedge clk) begin
        if (!resetn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            rx_read <= 0;
            wb_ack_o <= 0;
            wb_dat_o <= 0;
            // rx_released_d1 <= 0;
            // rx_released_d2 <= 0;
        end else begin
            rx_read <= 0;
            wb_ack_o <= 0;

            // Store previous released value (FF to avoid glitches)
            // rx_released_prev <= rx_releasd; 

            // PS/2 write to FIFO
            if ((rx_data_ready || rx_released_rising) && !fifo_full) begin
                // MSB indicates KeyUp or KeyDown event, needed for Doom logic
                fifo[wr_ptr] <= {~rx_released, rx_ascii[6:0]};
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
                rx_read <= 1;
            end else
                rx_released_prev <= rx_released;


            // Wishbone read from FIFO
            if (wb_stb_i && wb_cyc_i && !wb_ack_o) begin
                wb_ack_o <= 1;

                case (wb_adr_i[3:2])
                    2'b00: begin // DATA register
                        if (!fifo_empty) begin
                            wb_dat_o <= {24'd0, fifo[rd_ptr]};
                            rd_ptr   <= rd_ptr + 1;
                            count    <= count - 1;
                        end else begin
                            wb_dat_o <= 32'hFFFFFFFF;
                        end
                    end
                    2'b01: begin // STATUS register
                        wb_dat_o <= {30'd0, fifo_full, fifo_empty};
                    end
                    default: begin
                        wb_dat_o <= 32'hDEADBEEF;
                    end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        wb_err_o <= 1'b0;
        wb_rty_o <= 1'b0;
    end

endmodule
