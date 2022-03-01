// Top-level module instance
//
// Adrian Chadd, May 2021

module pll_setup(
       // 12MHz oscillator
       input clk_12,
       input reset,
       output pll_lock,
       output clk,
       output clk_2x
);

        // PLL instance
        wire clk, clk_2x;

        // Fin=12, FoutA=16, FoutB=32
	//
	// This .. does lock, but I manually fiddled and it
	// should /really/ be calculated via the tool to make
	// sure I get it right.
	//
	// DIVR:  0 (4'b0000)
	// DIVF: 84 (7'b1010100)
	// DIVQ:  5 (3'b101)
	//
	// FILTER_RANGE: 1 (3'b001)
	//
        SB_PLL40_2F_CORE #(
                .DIVR(4'b0000),
                .DIVF(7'b1010100),
                .DIVQ(3'b101),
                .FILTER_RANGE(3'b001),
                .FEEDBACK_PATH("SIMPLE"),
                .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
                .FDA_FEEDBACK(4'b0000),
                .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
                .FDA_RELATIVE(4'b0000),
                .SHIFTREG_DIV_MODE(2'b00),
                .PLLOUT_SELECT_PORTA("GENCLK_HALF"),
                .PLLOUT_SELECT_PORTB("GENCLK"),
                .ENABLE_ICEGATE_PORTA(1'b0),
                .ENABLE_ICEGATE_PORTB(1'b0)
        )

        pll_inst (
                .REFERENCECLK(clk_12),
                .PLLOUTCOREA(clk),
                .PLLOUTGLOBALA(),
                .PLLOUTCOREB(clk_2x),
                .PLLOUTGLOBALB(),
                .EXTFEEDBACK(),
                .DYNAMICDELAY(8'h00),
                .RESETB(1'b1),
                .BYPASS(1'b0),
                .LATCHINPUTVALUE(),
                .LOCK(pll_lock),
                .SDI(),
                .SDO(),
                .SCLK()
        );

endmodule

