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
        3'b000: begin
		    // Non-Jump
		    pc <= seq_pc;
		  end
		  
        3'b001: begin
		    // Jump (J)
		    pc <= {seq_pc[31:28], jmp_addr[25:0], 2'b00};
		  end
		  
        3'b010: begin
		    // Jump Register (JR)
		    pc <= reg_addr;
		  end
		  
        3'b011: begin
		    // Branch on EQ/NE (BEQ/BNE)
			 // PC = PC + (int) offset
		    pc <= seq_pc + {{14{branch_offset[15]}}, branch_offset[15:0], 2'b00};
		  end
		  
        default: begin
		    pc <= seq_pc;
		  end
      endcase
    end
  end

endmodule
