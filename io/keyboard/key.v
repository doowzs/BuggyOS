module key(
	input ps2_clk,
	input sys_clk,
	input rst,
	input ps2_data,
	output [31:0] ps2_ascii
);
	parameter 		ascii_l = 8'h61;
	parameter 		ascii_r = 8'h7F;

	reg 				nextdata_n;
	reg 				key_count_clk;
	reg 	[1:0] 	break_counter;
	reg 	[7:0] 	key_data_d;
	reg 	[7:0] 	key_ascii_d;
	reg 	[7:0] 	key_ascii_last;
	reg 	[7:0] 	key_scancode;
	
	wire 	[7:0] 	key_data;
	wire 	[7:0] 	key_ascii;
	wire 	[7:0] 	key_count_d;
	wire 				ready;
	wire 				overflow;
	wire 				to_upper;
	wire				to_ctrl;
	
	assign ps2_ascii = {{24{1'b0}}, key_ascii_d};
	
	ps2_keyboard keyhandler (
		.clk(sys_clk),
		.clrn(~rst),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
		.data(key_data),
		.ready(ready),
		.nextdata_n(nextdata_n),
		.overflow(overflow)
	);
	
	key_scancodes keymap (
		.address(key_scancode),
		.clock(sys_clk),
		.q(key_ascii)
	);
	
	key_counter keycounter (
		.clk(key_count_clk),
		.clrn(~rst),
		.is_break(break_counter),
		.code(key_data),
		.dst(key_count_d),
		.to_upper(to_upper),
		.to_ctrl(to_ctrl)
	);
	
	always @ (posedge sys_clk) begin
		key_count_clk <= 0;
		if (!ready) begin
			nextdata_n <= 1;
		end else begin
			nextdata_n <= 0;
			key_data_d <= key_data;
			if (key_data == 8'hF0) begin
				break_counter <= 2;
			end else begin
				key_scancode <= key_data;
				key_count_clk <= 1;
				if (break_counter > 0) begin 
					break_counter <= break_counter - 1;
				end
				if (break_counter == 1) begin
					key_data_d <= 0;
					key_scancode <= 0;
				end
			end
		end
	end
	
	always @ (posedge sys_clk) begin
		if (key_ascii >= ascii_l && key_ascii <= ascii_r) begin
			if (to_upper) begin
				key_ascii_d <= key_ascii - 8'h20;
			end else begin
				if (to_ctrl) begin
					key_ascii_d <= key_ascii - 8'h60;
				end else begin
					key_ascii_d <= key_ascii;
				end
			end
		end else begin
			key_ascii_d <= key_ascii;
		end
	end
	
endmodule 