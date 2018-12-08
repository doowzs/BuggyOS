module register_file(
  input           clk,
  input   [4:0]   raddr0,
  output  [31:0]  rdata0,
  input   [4:0]   raddr1,
  output  [31:0]  rdata1,
  input   [4:0]   waddr,
  input   [31:0]  wdata,
  input           wren,
  input           is_upper
);

  reg [31:0] reg_file [31:0];

  assign rdata0 = reg_file[raddr0];
  assign rdata1 = reg_file[raddr1];

  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      reg_file[i] = 0;
    end
  end

  always @ (posedge clk) begin
    if (wren) begin
	   if (is_upper) begin
		  reg_file[waddr] <= (wdata << 16);
		end else begin
        reg_file[waddr] <= wdata;
		end
    end
  end

endmodule 
