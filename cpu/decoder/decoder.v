`timescale 1ns / 1ps
module decoder(
  input         [31:0]  instr,
  input                 alu_zf,
  output reg            data_mem_wren,
  output reg            reg_file_wren,
  output reg            reg_file_dmux_sel,
  output reg            reg_file_rmux_sel,
  output reg            alu_imux_sel,
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

  always @ (*) begin
	 //---------------------------------------------
    // Determine addr, imm, rs/t/d, shamt, funct
    // for different types of instruction.
	 //---------------------------------------------
    casex (op)
      // R-type
      6'b000000: begin
        addr  <= {26{1'b0}};
        imm   <= {16{1'b0}};
        rs    <= instr[25:21];
        rt    <= instr[20:16];
        rd    <= instr[15:11];
        shamt <= instr[10:6];
        funct <= instr[5:0];
      end

      // J-type (J | JAL)
      6'b00001x: begin
        addr  <= instr[25:0];
        imm   <= {16{1'b0}};
        rs    <= {5{1'b0}};
        rt    <= {5{1'b0}};
        rd    <= {5{1'b0}};
        shamt <= {5{1'b0}};
        funct <= {6{1'b0}};
      end

      // I-type
      default: begin
        addr  <= {26{1'b0}};
        imm   <= instr[15:0];
        rs    <= instr[25:21];
        rt    <= instr[20:16];
        rd    <= {5{1'b0}};
        shamt <= instr[10:6];
        funct <= instr[5:0];
      end
    endcase
	 
	 //---------------------------------------------
	 // Set signals for ALU, PC, REG and MEMs.
	 // 
	 // data_mem_wren: set to write data to memory. 
	 // only set for Sx instructions (28~2E).
	 // 
	 // reg_file_wren: set to write data to registers. 
	 // Only NOT set for J, Branch and Sx instructions.
	 // 
	 // reg_file_dmux_sel: set to let ALU load data from register.
	 // If not set, ALU will load data from memory, only for Lx instructions.
	 // 
	 // reg_file_rmux_sel: set to use rd register instead of rt register.
	 // Only set for all R-type instructions.
	 // 
	 // alu_imux_sel: set to use immediate number instead of rt register.
	 // Only set for I-type instructions.
	 //---------------------------------------------
	 data_mem_wren <= 0;
	 reg_file_wren <= 0;
	 reg_file_dmux_sel <= 0;
	 reg_file_rmux_sel <= 0;
	 alu_imux_sel <= 0;
	 alu_op <= 4'b0000;
	 pc_control <= 3'b000;

    // Set signals for unit control purpose.
    // 1 - memory write signal
    // Only valid when instr is Sx instructions (28~2E)
	 if (op >= 6'b101000 && op <= 6'b101110) begin
		data_mem_wren <= 1;
	 end else begin
		data_mem_wren <= 0;
	 end
	 
    // 2 - register wren
    // Only invalid for JR(special-08), JALR(special-09), 
    // J(02), JAL(03), BEQ(04), BNE(05) and Sx(28~2E). 
    if ((op == 6'b000000 && funct >= 6'b001000 && funct <= 6'b001001) 
      || (op >= 6'b000010 && op <= 6'b000101) || (op >= 6'b101000 && op <= 6'b101110)) begin
      reg_file_wren <= 0;
    end else begin
      reg_file_wren <= 1;
    end
	 
    // 3 - register D-mux select
    // Only invalid for Lx instrs (20-26)
    if (op >= 6'b100000 && op <= 6'b100110) begin
      reg_file_dmux_sel <= 0;
    end else begin
      reg_file_dmux_sel <= 1;
    end
	 
    // 4 - register R-mux select
    // Only valid for R-type instructions.
    reg_file_rmux_sel <= (op == 6'b000000);
	 
    // 5 - ALU I-MUX select
    // Only valid for I-type instructions.
    // J(02) and JAL(03) are special judged. 
    if (op == 6'b000000 || op == 6'b000010 || op == 6'b000011) begin
      alu_imux_sel <= 0;
    end else begin
      alu_imux_sel <= 1;
    end
	 
	 //---------------------------------------------
    // Set ALU op-code according to instructions
	 //---------------------------------------------
    if ((op == 6'b000000 && funct == 6'b100100) || op == 6'b001100) begin
      // AND(0-24) | ANDI(0C)
      alu_op <= 4'b0001;
    end else if ((op == 6'b000000 && funct == 6'b100101) || op == 6'b001101) begin
      // OR(0-25) | ORI(0D)
      alu_op <= 4'b0010;
    end else if ((op == 6'b000000 && funct == 6'b100001) || op == 6'b001001) begin
      // ADDU(0-21) | ADDIU(09)
      alu_op <= 4'b0011;
    end else if (op == 6'b000000 && funct == 6'b100110) begin
      // XOR(0-26)
      alu_op <= 4'b0100;
    end else if (op == 6'b000000 && funct == 6'b100111) begin
      // NOR(0-27)
      alu_op <= 4'b0101;
    end else if (op == 6'b000000 && funct == 6'b100011) begin
      // SUBU(0-23)
      alu_op <= 4'b0110;
    end else if ((op == 6'b000000 && funct == 6'b101010) || op == 6'b001010) begin
      // SLT(0-2A) | SLTI(0A)
      alu_op <= 4'b0111;
    end else if (op == 6'b000000 && funct == 6'b000000) begin
      // SLL(0-00)
      alu_op <= 4'b1000;
    end else if (op == 6'b000000 && funct == 6'b000010) begin
      // SRL(0-02)
      alu_op <= 4'b1001;
    end else if (op == 6'b000000 && funct == 6'b000011) begin
      // SRA(0-03)
      alu_op <= 4'b1010;
    end else if ((op == 6'b000000 && funct == 6'b100000) || op == 6'b001000
      || op == 6'b100011 || op == 6'b101011) begin
      // ADD(0-20) | ADDI(08) | LW(23) | SW(2B)
      alu_op <= 4'b1011;
    end else if ((op == 6'b000000 && funct == 6'b100010) || op == 6'b000100 || op == 6'b000101) begin
      // SUB(0-22) | BEQ(04) | BNE(05)
      alu_op <= 4'b1100;
    end else begin
      alu_op <= 4'b0000;
    end
	 
	 //---------------------------------------------
    // Set PC control code according to instructions and ALU result
	 //---------------------------------------------
    #0.5 // avoid race condition
    if (op == 6'b000010 || op == 6'b000010) begin
      // J(02) | JAL(03)
      pc_control <= 3'b001;
    end else if (op == 6'b000000 && (funct == 6'b001000 || funct == 6'b001001)) begin
      // JR(0-08) | JALR(0-09)
      pc_control <= 3'b010;
    end else if (op == 6'b000100 && alu_zf == 1) begin
      // BEQ(04) Branching if equal
      pc_control <= 3'b011;
    end else if (op == 6'b000101 && alu_zf == 0) begin
      // BNE(05) Branching if not equal
      pc_control <= 3'b011;
    end else begin
      pc_control <= 3'b000;
    end

  end

endmodule 
