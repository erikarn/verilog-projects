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

	// Reset instance
	reset_top reset_inst(
		.NRST(NRST),
		.clk(clk),
		.pll_lock(pll_lock),
		.reset(reset)
	);

	// PLL instance
	pll_setup pll_inst(
		.clk_12(clk_12),
		.reset(reset),
		.pll_lock(pll_lock),
		.clk(clk),
		.clk_2x(clk_2x)
	);

endmodule
