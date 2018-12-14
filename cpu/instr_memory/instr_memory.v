module instr_memory(
  input   [31:0] addr,
  output  [31:0] instr
);

  wire [7:0] paddr;
  assign paddr = addr[9:2];

  // SIZE: 256 instructions.
  reg [31:0] instr_memory [255:0];
  
  initial begin
    $readmemh("program/keyboard.mips", instr_memory);
  end

  assign instr = instr_memory[paddr];

endmodule
