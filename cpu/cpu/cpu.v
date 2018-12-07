module cpu(
  input clk,
  input rst
)

  // Program counter and instruction
  wire [31:0] pc2addr;
  wire [31:0] instr;
  wire [31:0] instr_sign_ex;

  // Signals
  wire        signal_data_mem_wren;
  wire        signal_reg_file_wren;
  wire        signal_reg_file_dmux_sel;
  wire        signal_reg_file_rmux_sel;
  wire        signal_alu_mux_sel;
  wire  [3:0] signal_alu_op;
  wire  [2:0] signal_pc_control;

  // Registers
  wire  [4:0] reg_waddr;
  wire  [4:0] reg_raddr0;
  wire  [4:0] reg_raddr1;
  wire [31:0] reg_rdata0;
  wire [31:0] reg_rdata1;
  wire [31:0] reg_wdata;
  
  // ALU
  wire [31:0] alu_src;
  wire [31:0] alu_dest;
  wire        alu_eflags_of;
  wire        alu_eflags_zf;

  // Data Memory
  wire [31:0] data_mem_rdata;

  //-------------------------------------
  // Instantiations
  //-------------------------------------
  program_counter mPC(
    .clk(clk),
    .rst(rst),
    .pc_control(signal_pc_control),
    .jmp_addr(instr[25:0]),
    .branch_offset(instr[15:0]),
    .reg_addr(reg_rdata0),
    .pc(pc2addr)
  );

  instr_memory mINSTRMEM(
    .addr(pc2addr),
    .instr(instr)
  );

  decoder mDECODER(
    .instr(instr),
    .alu_zero(alu_eflags_zf),
    .data_mem_wren(signal_data_mem_wren),
    .reg_file_wren(signal_reg_file_wren),
    .reg_file_dmux_sel(signal_reg_file_dmux_sel),
    .reg_file_rmux_sel(signal_reg_file_rmux_sel),
    .alu_mux_sel(signal_alu_mux_sel),
    .alu_op(signal_alu_op),
    .pc_control(signal_pc_control)
  );

endmodule
