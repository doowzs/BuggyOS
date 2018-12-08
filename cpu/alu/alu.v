module alu(
  input       [3:0] op,
  input      [31:0] rs,
  input      [31:0] rt,
  output reg [31:0] rd,
  output            zf,
  output reg        of
);

  wire       [31:0] add;
  wire       [31:0] sub;

  assign add = rs + rt;
  assign sub = rs - rt;
  assign zf = (rd == 0);

  always @ (*) begin
    case (op)
      // AND
      4'b0001: begin
        rd <= rs & rt;
        of <= 0;
      end

      // OR
      4'b0010: begin
        rd <= rs | rt;
        of <= 0;
      end

      // Unsigned ADD
      4'b0011: begin
        rd <= add;
        of <= 0;
      end

      // XOR
      4'b0100: begin
        rd <= rs ^ rt;
        of <= 0;
      end

      // NOR
      4'b0101: begin
        rd <= ~(rs | rt);
        of <= 0;
      end

      // Unsigned SUB
      4'b0110: begin
        rd <= sub;
        of <= 0;
      end

      // Set on less than
      4'b0111: begin
        rd <= (rs < rt) ? -1 : 0;
        of <= 0;
      end

      // SHL
      4'b1000: begin
        rd <= rs << rt;
        of <= 0;
      end

      // SHR
      4'b1001: begin
        rd <= rs >> rt;
        of <= 0;
      end

      // SAR
      4'b1010: begin
        rd <= rs >>> rt;
        of <= 0;
      end

      // Signed ADD
      4'b1011: begin
        rd <= add;
        of <= (rs[31] == rt[31]) & (rs[31] != add[31]);
        $display("%d+%d=%d, of=%b", rs, rt, add, (rs[31] == rt[31]) & (rs[31] != add[31]));
      end

      // Signed SUB
      4'b1100: begin
        rd <= sub;
        of <= (rs[31] != rt[31]) & (rt[31] == sub[31]);
      end

      default: begin
		  // output rt so that LUI can work
        rd <= rt;
        of <= 0;
      end
    endcase
  end

endmodule 
