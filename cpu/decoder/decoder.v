`timescale 1ns / 1ps
module decoder(
  input         [31:0]  instr,
  input                 alu_zf,
  output reg            mem_wren,
  output reg            reg_wren,
  output reg            reg_dmux_sel,
  output reg            reg_rmux_sel,
  output reg				reg_is_upper,
  output reg            alu_imux_sel,
  output reg    [3:0]   alu_op,
  output reg    [2:0]   pc_control
);

  parameter ALU_IDLE = 4'b0000;
  parameter ALU_AND  = 4'b0001;
  parameter ALU_OR   = 4'b0010;
  parameter ALU_ADDU = 4'b0011;
  parameter ALU_XOR  = 4'b0100;
  parameter ALU_NOR  = 4'b0101;
  parameter ALU_SUBU = 4'b0110;
  parameter ALU_SLT  = 4'b0111;
  parameter ALU_SLL  = 4'b1000;
  parameter ALU_SRL  = 4'b1001;
  parameter ALU_SRA  = 4'b1010;
  parameter ALU_ADD  = 4'b1011;
  parameter ALU_SUB  = 4'b1100;
  
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
	 // mem_wren: set to write data to memory. 
	 // only set for Sx instructions (28~2E).
	 // 
	 // reg_wren: set to write data to registers. 
	 // Only NOT set for J, Branch and Sx instructions.
	 // 
	 // reg_dmux_sel: set to let ALU load data from register.
	 // If not set, ALU will load data from memory, only for Lx instructions.
	 // 
	 // reg_rmux_sel: set to use rd register instead of rt register.
	 // Only set for all R-type instructions.
	 // 
	 // alu_imux_sel: set to use immediate number instead of rt register.
	 // Only set for I-type instructions.
	 //---------------------------------------------
	 
	 mem_wren <= 0;     // Only for Sx instructions
	 reg_wren <= 1;     // DEFAULT IS 1!!!!!!!
	 reg_dmux_sel <= 1; // DEFAULT IS 1!!!!!!!
	 reg_rmux_sel <= 0; // Only for R-type instructions
	 reg_is_upper <= 0; // Only for LUI instruction
	 alu_imux_sel <= 1; // DEFAULT IS 1!!!!!!!
	 alu_op <= ALU_IDLE;
	 
	 case (op)
		// Special group
		6'b000000: begin
		  // set R-mux and I-mux for all R-type instructions
		  reg_rmux_sel <= 1;
		  alu_imux_sel <= 0;
		  case (funct)
		    // 00-00 SLL
			 6'b000000: begin
			   alu_op <= ALU_SLL;
			 end
			 // 00-02 SRL
			 6'b000010: begin
			   alu_op <= ALU_SRL;
			 end
			 // 00-03 SRA
			 6'b000011: begin
			   alu_op <= ALU_SRA;
			 end
			 // 00-08 JR
		    6'b001000: begin
			   reg_wren <= 0;
			 end
			 // 00-09 JAR   is not implemented!
			 // 00-20 ADD
			 6'b100000: begin
			   alu_op <= ALU_ADD;
			 end
			 // 00-21 ADDU
			 6'b100001: begin
			   alu_op <= ALU_ADDU;
			 end
			 // 00-22 SUB
			 6'b100010: begin
			   alu_op <= ALU_SUB;
			 end
			 // 00-23 SUBU
			 6'b100011: begin
			   alu_op <= ALU_SUB;
			 end
			 // 00-24 AND
			 6'b100100: begin
			   alu_op <= ALU_AND;
			 end
			 // 00-25 OR
			 6'b100101: begin
			   alu_op <= ALU_OR;
			 end
			 // 00-26 XOR
			 6'b100110: begin
			   alu_op <= ALU_XOR;
			 end
			 // 00-27 NOR
			 6'b100111: begin
			   alu_op <= ALU_NOR;
			 end
			 // 00-2A SLT
			 6'b101010: begin
			   alu_op <= ALU_SLT;
			 end
			 // 00-2B SLTU  is not implemented!
		  endcase
	   end
		
		// 02 J
		6'b000010: begin
		  alu_imux_sel <= 0;
		  reg_wren <= 0;
		end
		// 03 JAL
		6'b000011: begin
		  alu_imux_sel <= 0;
		  reg_wren <= 0;
		end
		// 04 BEQ
		6'b000100: begin
		  reg_wren <= 0;
		end
		// 05 BNE
		6'b000101: begin
		  reg_wren <= 0;
		end
		// 06 BLEZ  is not implemented!
		// 07 BGTZ  is not implemented!
		// 08 ADDI
		6'b001000: begin
		  alu_op <= ALU_ADD;
		end
		// 09 ADDIU
		6'b001001: begin
		  alu_op <= ALU_ADDU;
		end
		// 0A SLTI  is not implemented!
		// 0B SLTIU is not implemented!
		// 0C ANDI
		6'b001100: begin
		  alu_op <= ALU_AND;
		end
		// 0D ORI
		6'b001101: begin
		  alu_op <= ALU_OR;
		end
		// 0E XORI
		6'b001110: begin
		  alu_op <= ALU_XOR;
		end
		// 0F LUI
		6'b001111: begin
		  reg_is_upper <= 1;
		end
		// 14 BEQL  is not implemented!
		// 15 BNEL  is not implemented!
		// 16 BLEZL is not implemented!
		// 17 BGTZL is not implemented!
		// 20 LB    is not implemented!
		// 21 LH    is not implemented!
		// 22 LWL   is not implemented!
		// 23 LW
		6'b100011: begin
        reg_dmux_sel <= 0;
		  //alu_imux_sel <= 0;
      end 
		// 24 LBU   is not implemented!
		// 25 LHU   is not implemented!
		// 26 LWR   is not implemented!
		// 28 SB    is not implemented!
		// 29 SH    is not implemented!
		// 2A SWL   is not implemented!
		// 2B SW
		6'b101011: begin
		  mem_wren <= 1;
		  reg_wren <= 0;
		  //alu_imux_sel <= 0;
		end
		// 2E SWR   is not implemented!
	 endcase
  end
  
  always @ (op or alu_zf) begin
	 //---------------------------------------------
    // Set PC control code according to instructions and ALU result
	 //---------------------------------------------
	 pc_control <= 3'b000;
    if (op == 6'b000010 || op == 6'b000010) begin
      // J(02) | JAL(03)
      pc_control <= 3'b001;
    end else if (op == 6'b000000 && (funct == 6'b001000 || funct == 6'b001001)) begin
      // JR(00-08) | JALR(00-09)
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
