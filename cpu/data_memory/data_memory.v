module data_memory(
  input             clk,
  input     [31:0]  addr,
  input     [31:0]  wdata,
  input             wren,
  output    [31:0]  rdata
)

  // FIXME: use IP-kernel instead of regs!!!
  
  wire [15:0] paddr;
  assign paddr = addr[17:2];

  reg [7:0] memory0 [65535:0];
  reg [7:0] memory1 [65535:0];
  reg [7:0] memory2 [65535:0];
  reg [7:0] memory3 [65535:0];

  assign rdata = {
    memory3[paddr],
    memory2[paddr],
    memory1[paddr],
    memory0[paddr]
  };
  
  always @ (posedge clk) begin
    if (wren) begin
      memory0[paddr] <= wdata[7:0];
      memory1[paddr] <= wdata[15:8];
      memory2[paddr] <= wdata[23:16];
      memory3[paddr] <= wdata[31:24];
    end
  end

endmodule
