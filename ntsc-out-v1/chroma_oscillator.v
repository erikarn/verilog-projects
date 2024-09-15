// chroma oscillator module.

// From 03-19-19 E. Brombaugh; pulled out from Adrian Chadd, 2024

module chroma_oscillator(
	input clk,				// system clock (16MHz)
	input clk_2x,				// pixel clock (32MHz)
	input active_dly,			// active video, 1 pixel clock delay
	input reset,				// system reset,
	input [3:0] luma_sync_d2,		// luma, 2 pixel clock delay (to line up with chroma)
	input [1:0] gain,			// chroma gain
	input [2:0] phase,			// chroma phase
	input cb_dly,				// chroma burst enable, 1 pixel clock delay
	output reg [3:0] composite		// composite DAC video out
);

	// chroma oscillator
	reg [15:0] chroma_nco;
	reg [3:0] chroma_phs;
	reg [1:0] gain_d1, gain_d2;
	reg cb_d1, cb_d2, active_d1, active_d2;
	reg signed [3:0] chroma_osc, chroma;
	always @(posedge clk_2x)
	begin
		if(reset)
		begin
			chroma_nco <= 16'h0000;
		end
		else
		begin
			// NCO
			chroma_nco <= chroma_nco + 16'd7331;
			
			// phase reference or add in color
			if(!active_dly)
				chroma_phs <= chroma_nco[15:12];
			else
				chroma_phs <= chroma_nco[15:12] + {phase,1'b0};
			
			// simple sine LUT for oscillator
			case(chroma_phs)
				4'h0: chroma_osc <= 4'd0;
				4'h1: chroma_osc <= 4'd3;
				4'h2: chroma_osc <= 4'd5;
				4'h3: chroma_osc <= 4'd6;
				4'h4: chroma_osc <= 4'd7;
				4'h5: chroma_osc <= 4'd6;
				4'h6: chroma_osc <= 4'd5;
				4'h7: chroma_osc <= 4'd3;
				4'h8: chroma_osc <= 4'd0;
				4'h9: chroma_osc <= -4'd3;
				4'ha: chroma_osc <= -4'd5;
				4'hb: chroma_osc <= -4'd6;
				4'hc: chroma_osc <= -4'd7;
				4'hd: chroma_osc <= -4'd6;
				4'he: chroma_osc <= -4'd5;
				4'hf: chroma_osc <= -4'd3;
			endcase
			
			// gain piped
			gain_d1 <= gain;
			gain_d2 <= gain_d1;
			
			// chroma burst piped
			cb_d1 <= cb_dly;
			cb_d2 <= cb_d1;
			
			// active piped
			active_d1 <= active_dly;
			active_d2 <= active_d1;
			
			// chroma value
			if(cb_d2)
				chroma <= chroma_osc>>>2;	// colorburst
			else
			begin
				if(!active_d2 || (gain_d2 == 2'b00))
					chroma <= 4'h0;	// no chroma
				else
					chroma <= chroma_osc>>>(2'b11-gain);
			end
		end
	end
	
	// add luma/sync to chroma to generate composite
	reg signed [5:0] yc_sum;
	wire [3:0] sat_comp;
	always @(posedge clk_2x)
	begin
		yc_sum <= $signed({1'b0,luma_sync_d2}) + chroma;
		composite <= sat_comp;
	end
	
	// saturation from 6-bit signed to 4-bit unsigned
	satsu #(.isz(6),.osz(4)) usat(.in(yc_sum), .out(sat_comp));

endmodule
