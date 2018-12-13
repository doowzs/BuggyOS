module vga_control(
	input					pclk,
	input					reset_n,
	input		[11:0]	vga_data,
	output  	[11:0] 	vga_addr, // 0 ~ 2099
	output 	[9:0] 	vga_dx,   // 0 ~ 8
	output 	[9:0] 	vga_dy,   // 0 ~ 15
	output				hsync,
	output				vsync,
	output				valid,
	output	[7:0]		vga_r,
	output	[7:0]		vga_g,
	output	[7:0]		vga_b
);
	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 774; // last 10 is not used in lab11
	parameter h_total = 800;
	
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	
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
	always @ (posedge pclk or negedge reset_n) begin
		if (!reset_n) begin
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
	always @ (posedge pclk) begin
		if (!reset_n) begin
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
	assign vga_dx = h_valid ? dx : 5'h0;
	assign vga_dy = v_valid ? dy : 5'h0;

	assign vga_r = vga_data[dx] == 1 ? 8'hff : 8'h00;
	assign vga_g = vga_data[dx] == 1 ? 8'hff : 8'h00;
	assign vga_b = vga_data[dx] == 1 ? 8'hff : 8'h00;
endmodule 