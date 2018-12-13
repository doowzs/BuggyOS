module vga(
	input					vga_clk,
	input 				sys_clk,
	input					rst,
	input		 [7:0]	vga_ascii,
	output  	[15:0] 	vga_addr, // 0 ~ 2099
	output				hsync,
	output				vsync,
	output				valid,
	output	[7:0]		vga_r,
	output	[7:0]		vga_g,
	output	[7:0]		vga_b
);

	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 774; // last 10 is not used
	parameter h_total = 800;
	
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	
	wire [15:0] font_addr;
	wire [11:0] font_data;
	assign font_addr = {vga_ascii[7:0], 4'b0000} + dy;
	
	vga_font ascii2data (
		.address(font_addr),
		.clock(sys_clk),
		.q(font_data)
	);
	
	reg	[9:0]	x_cnt;
	reg	[9:0]	y_cnt;
	reg   [9:0] dx; // 0 ~ 8, initial at 8 to output dx-1!
	reg   [9:0] dy; // 0 ~ 15
	reg   [9:0] bx; // 0 ~ 29
	reg 	[9:0] by; // 0 ~ 69
	wire			h_valid;
	wire			v_valid;
	
	initial begin
		x_cnt <= 1;
		y_cnt <= 1;
		dx <= 8;
		dy <= 0;
		bx <= 0;
		by <= 0;
	end
	
	//x counter
	always @ (posedge vga_clk or posedge rst) begin
		if (rst) begin
			x_cnt <= 1;
			dx <= 8;
			bx <= 0;
		end else begin
			if (x_cnt == h_total) begin
				x_cnt <= 1;
			end else begin
				x_cnt <= x_cnt + 1;
			end
			if (h_valid) begin
				if (dx == 8) begin
					dx <= 0;
				end else begin
					dx <= dx + 1;
				end
				if (dx == 7) begin
					if (bx == 69) begin
						bx <= 0;
					end else begin
						bx <= bx + 1;
					end
				end
			end
		end
	end
	
	//y counter
	always @ (posedge vga_clk) begin
		if (rst) begin
			y_cnt <= 1;
			dy <= 0;
			by <= 0;
		end else begin
			if (x_cnt == h_total) begin
				if (y_cnt == v_total) begin
					y_cnt <= 1;
				end else begin
					y_cnt <= y_cnt + 1;
				end
				if (v_valid) begin
					if (dy == 15) begin
						dy <= 0;
						if (by == 29) begin
							by <= 0;
						end else begin
							by <= by + 1;
						end
					end else begin
						dy <= dy + 1;
					end
				end
			end
		end
	end
	
	assign hsync = (x_cnt > h_frontporch);
	assign vsync = (y_cnt > v_frontporch);
	
	assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
	assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
	assign valid = h_valid & v_valid;

	assign vga_addr = valid ? ({by[5:0], 6'h0} + {by[9:0], 2'b00} + {1'b0, by[9:0], 1'b0} + {2'b00, bx}) : 12'h0;

	assign vga_r = font_data[dx] == 1 ? 8'hff : 8'h00;
	assign vga_g = font_data[dx] == 1 ? 8'hff : 8'h00;
	assign vga_b = font_data[dx] == 1 ? 8'hff : 8'h00;
endmodule 