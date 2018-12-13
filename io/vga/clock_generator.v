module clock_generator(
	input clkin,
	input rst_n,
	input clken,
	output reg clkout
);
	parameter clk_freq = 1000;
	parameter countlimit = 50000000 / 2 / clk_freq;
	
	reg [31:0] clkcount;
	
	initial begin
		clkout = 0;
		clkcount = 0;
	end
	
	always @ (posedge clkin) begin
		if (!rst_n) begin
			clkcount = 0;
			clkout = 1'b0;
		end else begin
			if (clken) begin
				clkcount = clkcount + 1;
				if (clkcount >= countlimit) begin
					clkcount = 32'd0;
					clkout = ~clkout;
				end else begin
					clkout = clkout;
				end
			end else begin
				clkcount = clkcount;
				clkout = clkout;
			end
		end
	end
endmodule 