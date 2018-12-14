module io(
	input rst,
	input sys_clk,
   // LEDR
	input [9:0] led_in,
	output [9:0] led_out,
	// 7-SEG displays
	input [3:0] seg_in0,
	input [3:0] seg_in1,
	input [3:0] seg_in2,
	input [3:0] seg_in3,
	input [3:0] seg_in4,
	input [3:0] seg_in5,
	output [6:0] seg_out0,
	output [6:0] seg_out1,
	output [6:0] seg_out2,
	output [6:0] seg_out3,
	output [6:0] seg_out4,
	output [6:0] seg_out5,
	// VGA and PS2 Keyboard
	output [31:0] vk_addr,
	output        vk_wren,
	output [31:0] vk_wdata,
	input  [31:0] vk_rdata,
	input         vga_clk,
	output        vga_hsync,
	output        vga_vsync,
	output        vga_valid,
	output  [7:0] vga_data_r,
	output  [7:0] vga_data_g,
	output  [7:0] vga_data_b,
	input         ps2_clk,
	input         ps2_data
);

	parameter key_addr = 32'h000020D0;
	wire [31:0] vga_addr;

	assign led_out = led_in;
	assign vk_wren = (vk_wdata != 0);
	assign vk_addr = (vk_wdata != 0) ? key_addr : vga_addr;

	segment mSEG(
		.src0(seg_in0),
		.src1(seg_in1),
		.src2(seg_in2),
		.src3(seg_in3),
		.src4(seg_in4),
		.src5(seg_in5),
		.dst0(seg_out0),
		.dst1(seg_out1),
		.dst2(seg_out2),
		.dst3(seg_out3),
		.dst4(seg_out4),
		.dst5(seg_out5)
	);
	
	vga mVGA(
		.vga_clk(vga_clk),
		.sys_clk(sys_clk),
		.rst(rst),
		.vga_ascii(vk_rdata),
		.vga_addr(vga_addr),
		.hsync(vga_hsync),
		.vsync(vga_vsync),
		.valid(vga_valid),
		.vga_r(vga_data_r),
		.vga_g(vga_data_g),
		.vga_b(vga_data_b)
	);
	
	key mKEY(
		.ps2_clk(ps2_clk),
		.sys_clk(sys_clk),
		.rst(rst),
		.ps2_data(ps2_data),
		.ps2_ascii(vk_wdata)
	);
	
endmodule 