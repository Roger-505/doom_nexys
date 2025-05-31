`timescale 1ns / 1ps

module tb_clk_gen_nexys;

  reg i_clk = 0;
  reg i_rst = 1;
  wire o_clk_core;
  wire o_clk_vga;
  wire o_rst_core;

  // Clock generation: 100 MHz => 10 ns period
  always #5 i_clk = ~i_clk;

  // DUT instantiation
  clk_gen_nexys uut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_clk_core(o_clk_core),
    .o_clk_vga(o_clk_vga),
    .o_rst_core(o_rst_core)
  );

  initial begin
    $display("Starting simulation...");
    $dumpfile("clk_gen_nexys_tb.vcd");
    $dumpvars(0, tb_clk_gen_nexys);

    // Hold reset high initially
    #100;
    i_rst = 0;

    // Simulate long enough to observe PLL lock and outputs
    #2000;

    $display("Finished simulation.");
    $finish;
  end

endmodule
