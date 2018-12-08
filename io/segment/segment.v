module segment(
	input [3:0] src0,
	input [3:0] src1,
	input [3:0] src2,
	input [3:0] src3,
	input [3:0] src4,
	input [3:0] src5,
	output [6:0] dst0,
	output [6:0] dst1,
	output [6:0] dst2,
	output [6:0] dst3,
	output [6:0] dst4,
	output [6:0] dst5
);
	
	hex_display h0(
		.src(src0),
		.dst(dst0)
	);
	hex_display h1(
		.src(src1),
		.dst(dst1)
	);
	hex_display h2(
		.src(src2),
		.dst(dst2)
	);
	hex_display h3(
		.src(src3),
		.dst(dst3)
	);
	hex_display h4(
		.src(src4),
		.dst(dst4)
	);
	hex_display h5(
		.src(src5),
		.dst(dst5)
	);
	
endmodule 