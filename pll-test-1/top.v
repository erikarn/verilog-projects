// Top-level module instance
//
// Adrian Chadd, May 2021

`default_nettype none

module ntsc_out_top(
	// 12MHz oscillator
	input clk_12,
	// Reset input
	input NRST,
	// Video
	inout [3:0] vdac,
	// PLL lock notification
	output pll_lock,
	// System reset
	output reset,
	// 16MHz output
	output clk,
	// 32MHz output
	output clk_2x
);

	wire clk_out, clk_2x_out;

	// Buffer between clock PLL output and consumers
	SB_GB clk_out_buffer(
		.USER_SIGNAL_TO_GLOBAL_BUFFER(clk_out),
		.GLOBAL_BUFFER_OUTPUT(clk)
	);

	SB_GB clk_2x_out_buffer(
		.USER_SIGNAL_TO_GLOBAL_BUFFER(clk_2x_out),
		.GLOBAL_BUFFER_OUTPUT(clk_2x)
	);

	// Reset instance
	reset_top reset_inst(
		.NRST(NRST),
		.clk(clk_out),
		.pll_lock(pll_lock),
		.reset(reset)
	);

	// PLL instance
	pll_setup pll_inst(
		.clk_12(clk_12),
		.reset(reset),
		.pll_lock(pll_lock),
		.clk(clk_out),
		.clk_2x(clk_2x_out)
	);

endmodule
