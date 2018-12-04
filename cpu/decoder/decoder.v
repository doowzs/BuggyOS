module decoder(
  input         [31:0]  instr,
  input                 alu_zero,
  output reg    [3:0]   data_mem_wren,
  output reg            reg_file_wren,
  output reg            reg_file_dmux_sel,
  output reg            reg_file_rmux_sel,
  output reg            alu_mux_sel,
  output reg    [3:0]   alu_op,
  output reg    [2:0]   pc_control
);
  
  reg   [25:0]  addr;
  reg   [5:0]   funct;
  reg   [4:0]   shamt;
  reg   [15:0]  imm;
  reg   [4:0]   rs;
  reg   [4:0]   rt;
  reg   [4:0]   rd;

  wire  [5:0]   op;
  assign op = instr[31:26];

  always @ (instr) begin
    // Determine addr, imm, rs/t/d, shamt, funct
    // for different types of instruction.
    casex (op)
      // R-type
      6'b000000: begin
        addr  <= {{26, 1'b0}};
        imm   <= {{16, 1'b0}};
        rs    <= instr[25:21];
        rt    <= instr[20:16];
        rd    <= instr[15:11];
        shamt <= instr[10:6];
        funct <= instr[5:0];
      end

      // J-type
      6'b00001x: begin
        addr  <= instr[25:0];
        imm   <= {{16. 1'b0}};
        rs    <= {{5, 1'b0}};
        rt    <= {{5, 1'b0}};
        rd    <= {{5, 1'b0}};
        shamt <= {{5, 1'b0}};
        funct <= {{6, 1'b0}};
      end

      // I-type
      default: begin
        addr  <= {{26, 1'b0}};
        imm   <= instr[15:0];
        rs    <= instr[25:21];
        rt    <= instr[20:16];
        rd    <= {{5, 1'b0}};
        shamt <= instr[10:6];
        funct <= instr[5:0];
      end
    endcase

    // Set signals for unit control purpose.
    // 1 - memory wren
    // 2 - register wren
    // 3 - register D-mux select
    // 4 - register R-mux select
    // 5 - ALU MUX select
    // 6 - ALU op-code
    // 7 - PC Control

  end

endmodule 
