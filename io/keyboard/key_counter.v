module key_counter(clk, clrn, is_break, code, dst, to_upper, to_ctrl);
	input clk;
	input clrn;
	input [1:0] is_break;
	input [7:0] code;
	output reg [7:0] dst;
	output reg to_upper;
	output reg to_ctrl;
	
	reg [127: 0] key_reg;
	
	initial begin
		dst <= 0;
		key_reg <= 0;
	end
	
	always @ (posedge clk or negedge clrn) begin
		to_upper <= key_reg[8'h12]; // SHIFT(0x12) pressed?
		to_ctrl <= key_reg[8'h14]; // CONTROL(0x14) pressed?
		if (!clrn) begin
			dst <= 0;
			key_reg <= 0;
		end else begin
			if (is_break == 0 && code != 8'hF0) begin
				if (key_reg[code] == 0) begin
					key_reg[code] <= 1;
					dst <= dst + 1;
				end
			end else begin
				key_reg[code] <= 0;
			end
		end
	end
endmodule 