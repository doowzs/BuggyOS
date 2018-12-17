module instr_memory(
  input   [31:0] addr,
  output  [31:0] instr
);

  wire [9:0] paddr;
  assign paddr = addr[11:2];

  // SIZE: 256 instructions.
  reg [31:0] instr_memory [1023:0];
  
  initial begin
    $readmemh("program/system.mips", instr_memory);
  end

  assign instr = instr_memory[paddr];

endmodule
