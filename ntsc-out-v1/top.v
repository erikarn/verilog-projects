// Top-level module instance
//
// Adrian Chadd, May 2021

`default_nettype none

module ntsc_out_top(
	// Reset input
	input NRST,
	// Video
	inout [3:0] vdac,
	input clk_12,
	output pll_lock,
	output reset,
	output clk,
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
		.clk(clk),
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

	// For now we don't write into the video controller
	wire sel_ram = 1'b0;
	wire sel_ctl = 1'b0;
	wire we = 1'b0;

	// None of these do anything right now; we're not populating
	// VRAM at all.
	wire [12:0] ram_addr = 12'b0;
	wire [7:0] ram_data_in = 8'b0;
	wire [7:0] ram_data_out;
	wire [7:0] ctrl_data_out;

	// video output wiring betwee nvideo and SB_IO block
	wire [3:0] composite;

	// Video
	video video_inst(
		.clk(clk),
		.clk_2x(clk_2x),
		.reset(reset),
		.sel_ram(sel_ram),
		.sel_ctl(sel_ctl),
		.we(we),
		.addr(ram_addr),
		.din(ram_data_in),
		.ram_dout(ram_data_out),
		.ctl_dout(ctrl_data_out),
		.composite(composite)
	);

	// video DAC output register & drivers
	SB_IO #(
		.PIN_TYPE(6'b101001),
		.PULLUP(1'b1),
		.NEG_TRIGGER(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	) uvdac[3:0] (
		.PACKAGE_PIN(vdac),
		.LATCH_INPUT_VALUE(1'b0),
		.CLOCK_ENABLE(1'b1),
		.INPUT_CLK(1'b0),
		.OUTPUT_CLK(clk_2x),
		.OUTPUT_ENABLE(1'b1),
		.D_OUT_0(composite[3:0]),
		.D_OUT_1(1'b0),
		.D_IN_0(),
		.D_IN_1()
	);

endmodule

