// Reset signal debounce/generator for rest of design
//
// Adrian Chadd, May 2021

module reset_top(
	// Extern reset input
	input NRST,
	// System clock
	input clk,
	// PLL lock status
	input pll_lock,
	// System reset
	output reg reset
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

