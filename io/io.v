module io(
	input [9:0] led_in,
	output [9:0] led_out,
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
	output [6:0] seg_out5
);

	assign led_out = led_in;

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
	
endmodule 