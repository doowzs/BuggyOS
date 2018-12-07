`timescale 1ns / 1ps
module decoder(
  input         [31:0]  instr,
  input                 alu_zero,
  output reg            data_mem_wren,
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
    // Only valid when instr is SW (store word)
    data_mem_wren <= (op == 6'b101010) | (op == 6'b101011);
    // 2 - register wren
    // Only invalid for JR(special-08), JALR(special-09), 
    // J(02), JAL(03), BEQ(04), BNE(05). 
    if (op == 6'h00 & funct >= 6'h08 & funct <= 6'h09) 
      | (op >= 6'h02 & op <= 6'h05) begin
      reg_file_wren <= 0;
    end else begin
      reg_file_wren <= 1;
    end
    // 3 - register D-mux select
    // Only invalid for LoadWord (20~26)
    if (op >= 6'h20 & op <= 6'h26) begin
      reg_file_dmux_sel <= 0;
    end else begin
      reg_file_dmux_sel <= 1;
    end
    // 4 - register R-mux select
    // Only valid for R-type instructions.
    reg_file_rmux_sel <= (op == 6'h00);
    // 5 - ALU MUX select
    // Only valid for I-type instructions.
    // J(02) and JAL(03) are special judged. 
    if (op == 6'h00 | op == 6'h02 | op == 6'h03) begin
      alu_mux_sel <= 1;
    end else begin
      alu_mux_sel <= 0;
    end
    // 6 - ALU op-code
    if ((op == 6'h00 & funct == 6'h24) | op == 6'h0C) begin
      // AND(0-24) | ANDI(0C)
      alu_control <= 4'b0000;
    end else if ((op == 6'h00 & funct == 6'h25) | op == 6'h0D) begin
      // OR(0-25) | ORI(0D)
      alu_control <= 4'b0001;
    end else if ((op == 6'h00 & funct == 6'h21) | op == 6'h09) begin
      // ADDU(0-21) | ADDIU(09)
      alu_control <= 4'b0010;
    end else if (op == 6'h00 & funct == 6'h26) begin
      // XOR(0-26)
      alu_control <= 4'b0011;
    end else if (op == 6'h00 & funct == 6'h27) begin
      // NOR(0-27)
      alu_control <= 4'b0100;
    end else if (op == 6'h00 & funct == 6'h23) begin
      // SUBU(0-23)
      alu_control <= 4'b0110;
    end else if ((op == 6'h00 & funct == 6'h2A) | op == 6'h0A) begin
      // SLT(0-2A) | SLTI(0A)
      alu_control <= 4'b0111;
    end else if (op == 6'h00 & funct == 6'h00) begin
      // SLL(0-00)
      alu_control <= 4'b1000;
    end else if (op == 6'h00 & funct == 6'h02) begin
      // SRL(0-02)
      alu_control <= 4'b1001;
    end else if (op == 6'h00 & funct == 6'h03) begin
      // SRA(0-03)
      alu_control <= 4'b1010;
    end else if ((op == 6'h00 & funct == 6'h20) | op == 6'h08
      | op == 6'h23 | op == 6'h2B) begin
      // ADD(0-20) | ADDI(08) | LW(23) | SW(2B)
      alu_control <= 4'b1011;
    end else if ((op == 6'h00 & funct == 6'h22) | op == 6'h04 | op == 6'h05) begin
      // SUB(0-22) | BEQ(04) | BNE(05)
      alu_control <= 4'b1110;
    end else begin
      alu_control <= 4'b1111;
    end
    // 7 - PC Control
    #0.5 // avoid race condition
    if (op == 6'h02 | op == 6'h03) begin
      // J(02) | JAL(03)
      pc_control <= 3'b001;
    end else if (op == 6'h00 & (funct == 6'h08 | funct == 6'h09)) begin
      // JR(0-08) | JALR(0-09)
      pc_control <= 3'b010;
    end else if (op == 6'h04 & alu_zf == 1) begin
      // BEQ(04)
      $display("###beq");
      pc_control <= 3'b011;
    end else if (op == 6'h05 & alu_zf == 0) begin
      // BNE(05)
      $display("###bne");
      pc_control <= 3'b011;
    end else begin
      pc_control <= 3'b000;
    end

  end

endmodule 
