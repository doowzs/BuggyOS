module vga(
	input							vga_clk,
	input 						sys_clk,
	input							rst,
	input             		vga_refresh_wren,
	input				[31:0]	vga_refresh_data,
	output  wire 	[31:0] 	vga_refresh_addr,
	output						hsync,
	output						vsync,
	output						valid,
	input          [31:0]   vga_rgba,
	output	    	[7:0]		vga_r,
	output	    	[7:0]		vga_g,
	output	    	[7:0]		vga_b
);

	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 774; // last 10 is not used
	parameter h_total = 800;
	
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	
	wire  [7:0] ascii_data;
	wire [11:0] vga_addr;
	wire [11:0] font_addr;
	wire [11:0] font_data;
	assign font_addr = {ascii_data[7:0], 4'b0000} + dy;
	assign vga_refresh_addr = {{18{1'b0}}, vga_addr[11:0], {2{1'b0}}}; // addr * 4
	
	// A port is internal, always reading data;
	// B port is external, will refresh if there is no input from keyboard.
	vga_ram addr2ascii (
		.clock(sys_clk),
		.data(vga_refresh_data[7:0]),
		.rdaddress(vga_addr),
		.wraddress(vga_addr),
		.wren(vga_refresh_wren),
		.q(ascii_data)
	);
	
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
		dx <= 0;
		dy <= 0;
		bx <= 0;
		by <= 0;
	end
	
	//x counter
	always @ (posedge vga_clk or posedge rst) begin
		if (rst) begin
			x_cnt <= 1;
			dx <= 0;
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

	assign vga_addr = {by[5:0], 6'h0} + {by[9:0], 2'b00} + {1'b0, by[9:0], 1'b0} + {2'b00, bx};

	wire font_valid = (font_data[dx - 1] == 1);
	assign vga_r = font_valid ? vga_rgba[31:24] : 8'h00;
	assign vga_g = font_valid ? vga_rgba[23:16] : 8'h00;
	assign vga_b = font_valid ? vga_rgba[15:8] : 8'h00;
endmodule 