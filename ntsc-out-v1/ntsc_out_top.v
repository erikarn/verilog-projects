// Top-level module instance
//
// Adrian Chadd, May 2021

`default_nettype none

module ntsc_out_top(
	// Reset input
	input NRST_IN,
	// Video
	inout [3:0] vdac,
	input clk_12
);

	wire clk_out, clk_2x_out;	// PLL block output

	wire clk, clk_2x;		// Global buffers for clock routing
	wire pll_lock;			// Whether the clock PLL is locked
	wire reset;			// System wide reset wire, against clk_2x
	wire NRST;			// SB_IO reset

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

	// Reset line input buffer
	//
	SB_IO #(
		.PIN_TYPE(6'b000001),	// [1:0] = 01 = INPUT (simple) [5:2] = PIN_NO_OUTPUT
		.PULLUP(1'b1),		// 1 = pull-up resistor enabled (default 100k)
		.NEG_TRIGGER(1'b0),	// Rising or falling edge on flip flop triggers in IO block
		.IO_STANDARD("SB_LVCMOS")
	) NRST_IO (
		.PACKAGE_PIN(NRST_IN),	// which package pin to use!
		.LATCH_INPUT_VALUE(1'b0), // 1 = hold the last pad value, 0 = input runs freely
		.CLOCK_ENABLE(1'b1),	// clock common to input / output
		.INPUT_CLK(clk_2x),	// input clock
		.OUTPUT_CLK(1'b0),	// output clock
		.OUTPUT_ENABLE(1'b0),	// output enable - 0 for tri-state
		.D_OUT_0(1'b0),		// output on rising clock edge
		.D_OUT_1(1'b0),		// output on falling clock edge
		.D_IN_0(NRST),		// input on rising clock edge
		.D_IN_1()		// input on falling clock edge
	);

	// video DAC output register & drivers
	SB_IO #(
		.PIN_TYPE(6'b101001),	// [1:0] = 01 = INPUT (simple) [5:2] = PIN_OUTPUT_TRISTATE
		.PULLUP(1'b1),		// pull-up resistor enabled (default 100k)
		.NEG_TRIGGER(1'b0),	// Rising or falling edge on flip flop triggers in IO block
		.IO_STANDARD("SB_LVCMOS")
	) uvdac[3:0] (
		.PACKAGE_PIN(vdac),	// which package pin to use!
		.LATCH_INPUT_VALUE(1'b0), // 1 = hold the last pad value, 0 = input runs freely
		.CLOCK_ENABLE(1'b1),	// clock common to input / output
		.INPUT_CLK(1'b0),	// input clock
		.OUTPUT_CLK(clk_2x),	// output clock
		.OUTPUT_ENABLE(1'b1),	// output enable - 0 for tri-state
		.D_OUT_0(composite[3:0]),	// output on rising clock edge
		.D_OUT_1(1'b0),		// output on falling clock edge
		.D_IN_0(),		// input on rising clock edge
		.D_IN_1()		// input on falling clock edge
	);

endmodule

