module hex_display(dst, src);
	input [3:0] src;
	output reg [6:0] dst;
	
	always @ (src)
	begin
	   case (src)
	     4'd0:  dst = 7'b1000000;
		  4'd1:  dst = 7'b1111001;
		  4'd2:  dst = 7'b0100100;
	  	  4'd3:  dst = 7'b0110000;
		  4'd4:  dst = 7'b0011001;
	  	  4'd5:  dst = 7'b0010010;
		  4'd6:  dst = 7'b0000010;
		  4'd7:  dst = 7'b1111000;
		  4'd8:  dst = 7'b0000000;
		  4'd9:  dst = 7'b0010000;
		  4'd10: dst = 7'b0001000;
		  4'd11: dst = 7'b0000011;
		  4'd12: dst = 7'b1000110;
		  4'd13: dst = 7'b0100001;
		  4'd14: dst = 7'b0000110;
		  4'd15: dst = 7'b0001110;
		  default: dst = 7'b0111111;
	   endcase
	end
	
endmodule 