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
       output pll_lock,
       output reset,
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
        SB_PLL40_2F_PAD #(
                .DIVR(4'b010),
                .DIVF(7'b0111111),
                .DIVQ(3'b011),
                .FILTER_RANGE(3'b010),
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
                .PACKAGEPIN(clk_12),
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

        // external reset debounce
        reg [7:0] ercnt;
        reg erst;
        always @(posedge clk)
        begin
                if(NRST == 1'b0)
                begin
                        ercnt <= 8'h00;
                        erst <= 1'b1;
                end
                else
                begin
                        if(!ercnt)
                                ercnt <= ercnt + 8'h01;
                        else
                                erst <= 1'b0;
                end
        end

        // reset generator waits > 10us
        reg [7:0] reset_cnt;
        reg reset;
        always @(posedge clk)
        begin
                if(!pll_lock)
                begin
                        reset_cnt <= 8'h00;
                        reset <= 1'b1;
                end
                else
                begin
                        if(reset_cnt != 8'hff)
                        begin
                                reset_cnt <= reset_cnt + 8'h01;
                                reset <= 1'b1;
                        end
                        else
                                reset <= erst;
                end
        end

endmodule

