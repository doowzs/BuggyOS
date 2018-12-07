module program_counter(
  input              clk,
  input              rst,
  input       [2:0]  pc_control,
  input      [25:0]  jmp_addr,
  input      [15:0]  branch_offset,
  input      [31:0]  reg_addr,
  output reg [31:0]  pc
);

  wire [31:0] seq_pc; // next pc address
  assign seq_pc = pc + 4;

  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      // RESET
      pc <= 32'h00000000;
    end else begin
      case (pc_control)
        3'b000: pc <= seq_pc;
        3'b001: pc <= {seq_pc{31:28}, jmp_addr[25:0], 2'b00};
        3'b010: pc <= reg_addr;
        3'b011: pc <= seq_pc + {{14{branch_offset[15]}}, branch_offset[15:0], 2'b00};
        default: pc <= seq_pc;
      endcase
    end
  end

endmodule
