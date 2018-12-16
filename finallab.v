//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module finallab(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

	wire [9:0] wire_ledr;
	wire [3:0] wire_seg0;
	wire [3:0] wire_seg1;
	wire [3:0] wire_seg2;
	wire [3:0] wire_seg3;
	wire [3:0] wire_seg4;
	wire [3:0] wire_seg5;
	wire [31:0] wire_io_addr;
	wire        wire_io_wren;
	wire [31:0] wire_io_wdata;
	wire [31:0] wire_io_rdata;
	
	wire rst = (~KEY[3]) & (~KEY[0]);
	wire CPU_CLK;
	reg  signal_use_manual_clk;
	reg  m_cpu_clk;
	
	clock_generator #(25000000) my_vgaclk(
		CLOCK_50, ~rst, 1'b1, VGA_CLK
	);
	
	clock_generator #(1000) my_cpuclk(
		CLOCK_50, ~rst, KEY[0], CPU_CLK
	);

	cpu mCPU(
		.clk(m_cpu_clk),
		.sys_clk(CLOCK_50),
		.rst(rst),
		.SW(SW),
		.KEY(KEY),
		.io_addr(wire_io_addr),
		.io_wren(wire_io_wren),
		.io_wdata(wire_io_wdata),
		.io_rdata(wire_io_rdata),
		.LEDR(wire_ledr),
		.SEG({
			wire_seg5[3:0], wire_seg4[3:0],
			wire_seg3[3:0], wire_seg2[3:0],
			wire_seg1[3:0], wire_seg0[3:0]
		})
	);
	
	io mIO(
		.rst(rst),
		.sys_clk(CLOCK_50),
		.led_in(wire_ledr),
		.led_out(LEDR),
		.seg_in0(wire_seg0),
		.seg_out0(HEX0),
		.seg_in1(wire_seg1),
		.seg_out1(HEX1),
		.seg_in2(wire_seg2),
		.seg_out2(HEX2),
		.seg_in3(wire_seg3),
		.seg_out3(HEX3),
		.seg_in4(wire_seg4),
		.seg_out4(HEX4),
		.seg_in5(wire_seg5),
		.seg_out5(HEX5),
		.vk_addr(wire_io_addr),
		.vk_wren(wire_io_wren),
		.vk_wdata(wire_io_wdata),
		.vk_rdata(wire_io_rdata),
		.vga_clk(VGA_CLK),
		.vga_hsync(VGA_HS),
		.vga_vsync(VGA_VS),
		.vga_valid(VGA_BLANK_N),
		.vga_data_r(VGA_R),
		.vga_data_g(VGA_G),
		.vga_data_b(VGA_B),
		.ps2_clk(PS2_CLK),
		.ps2_data(PS2_DAT)
	);


//=======================================================
//  Structural coding
//=======================================================



endmodule
