module biriscv_exec
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           opcode_valid_i
    ,input  [ 31:0]  opcode_opcode_i
    ,input  [ 31:0]  opcode_pc_i
    ,input           opcode_invalid_i
    ,input  [  4:0]  opcode_rd_idx_i
    ,input  [  4:0]  opcode_ra_idx_i
    ,input  [  4:0]  opcode_rb_idx_i
    ,input  [ 31:0]  opcode_ra_operand_i
    ,input  [ 31:0]  opcode_rb_operand_i
    ,input           hold_i

    // Outputs
    ,output          branch_request_o
    ,output          branch_is_taken_o
    ,output          branch_is_not_taken_o
    ,output [ 31:0]  branch_source_o
    ,output          branch_is_call_o
    ,output          branch_is_ret_o
    ,output          branch_is_jmp_o
    ,output [ 31:0]  branch_pc_o
    ,output          branch_d_request_o
    ,output [ 31:0]  branch_d_pc_o
    ,output [  1:0]  branch_d_priv_o
    ,output [ 31:0]  writeback_value_o
);



//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "biriscv_defs_dec.v"
`include "biriscv_defs_alu.v"

//-------------------------------------------------------------
// Opcode decode
//-------------------------------------------------------------
reg [31:0]  I_imm_r;
reg [31:0]  S_imm_r;
reg [31:0]  B_imm_r;
reg [31:0]  U_imm_r;
reg [31:0]  J_imm_r;
reg [31:0]  shamt_r;

always @* begin
  shamt_r = {           1'b0    , {11{           1'b0       }}, {9{           1'b0       }},            1'b0    , {6{        1'b0     }}, opcode_opcode_i[24:21], opcode_opcode_i[20]};
  I_imm_r = {opcode_opcode_i[31], {11{opcode_opcode_i[31   ]}}, {9{opcode_opcode_i[31   ]}},                      opcode_opcode_i[30:25], opcode_opcode_i[24:21], opcode_opcode_i[20]};
  S_imm_r = {opcode_opcode_i[31], {11{opcode_opcode_i[31   ]}}, {9{opcode_opcode_i[31   ]}},                      opcode_opcode_i[30:25], opcode_opcode_i[11: 8], opcode_opcode_i[ 7]};
  B_imm_r = {opcode_opcode_i[31], {11{opcode_opcode_i[31   ]}}, {8{opcode_opcode_i[31   ]}}, opcode_opcode_i[ 7], opcode_opcode_i[30:25], opcode_opcode_i[11: 8],            1'b0    };
  U_imm_r = {opcode_opcode_i[31],     opcode_opcode_i[30:20]  ,    opcode_opcode_i[19:12]  ,            1'b0    , {6{        1'b0     }}, {4{        1'b0     }},            1'b0    };
  J_imm_r = {opcode_opcode_i[31], {11{opcode_opcode_i[31   ]}},    opcode_opcode_i[19:12]  , opcode_opcode_i[20], opcode_opcode_i[30:25], opcode_opcode_i[24:21],            1'b0    };
end

//-------------------------------------------------------------
// Execute - ALU operations
//-------------------------------------------------------------
reg [3:0]  alu_func_r;
reg [31:0] alu_input_a_r;
reg [31:0] alu_input_b_r;

always @* begin:ALU_DEC
  if ((opcode_opcode_i & `INST_ADD_MASK) == `INST_ADD) begin:ADD
    alu_func_r     = `ALU_ADD;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_AND_MASK) == `INST_AND) begin:AND
    alu_func_r     = `ALU_AND;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_OR_MASK) == `INST_OR) begin:OR
    alu_func_r     = `ALU_OR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SLL_MASK) == `INST_SLL) begin:SLL
    alu_func_r     = `ALU_SHIFTL;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SRA_MASK) == `INST_SRA) begin:SRA
    alu_func_r     = `ALU_SHIFTR_ARITH;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SRL_MASK) == `INST_SRL) begin:SRL
    alu_func_r     = `ALU_SHIFTR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SUB_MASK) == `INST_SUB) begin:SUB
    alu_func_r     = `ALU_SUB;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_XOR_MASK) == `INST_XOR) begin:XOR
    alu_func_r     = `ALU_XOR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SLT_MASK) == `INST_SLT) begin:SLT
    alu_func_r     = `ALU_LESS_THAN_SIGNED;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_SLTU_MASK) == `INST_SLTU) begin:SLTU
    alu_func_r     = `ALU_LESS_THAN;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = opcode_rb_operand_i;
  end else
  if ((opcode_opcode_i & `INST_ADDI_MASK) == `INST_ADDI) begin:ADDI
    alu_func_r     = `ALU_ADD;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_ANDI_MASK) == `INST_ANDI) begin:ANDI
    alu_func_r     = `ALU_AND;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_SLTI_MASK) == `INST_SLTI) begin:SLTI
    alu_func_r     = `ALU_LESS_THAN_SIGNED;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_SLTIU_MASK) == `INST_SLTIU) begin:SLTIU
    alu_func_r     = `ALU_LESS_THAN;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_ORI_MASK) == `INST_ORI) begin:ORI
    alu_func_r     = `ALU_OR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_XORI_MASK) == `INST_XORI) begin:XORI
    alu_func_r     = `ALU_XOR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = I_imm_r;
  end else
  if ((opcode_opcode_i & `INST_SLLI_MASK) == `INST_SLLI) begin:SLLI
    alu_func_r     = `ALU_SHIFTL;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = shamt_r;
  end else
  if ((opcode_opcode_i & `INST_SRLI_MASK) == `INST_SRLI) begin:SRLI
    alu_func_r     = `ALU_SHIFTR;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = shamt_r;
  end else
  if ((opcode_opcode_i & `INST_SRAI_MASK) == `INST_SRAI) begin:SRAI
    alu_func_r     = `ALU_SHIFTR_ARITH;
    alu_input_a_r  = opcode_ra_operand_i;
    alu_input_b_r  = shamt_r;
  end else
  if ((opcode_opcode_i & `INST_LUI_MASK) == `INST_LUI) begin:LUI
    alu_func_r     = `ALU_NONE;
    alu_input_a_r  = U_imm_r;
    alu_input_b_r  = 32'b0;
  end else
  if ((opcode_opcode_i & `INST_AUIPC_MASK) == `INST_AUIPC) begin:AUIPC
    alu_func_r     = `ALU_ADD;
    alu_input_a_r  = opcode_pc_i;
    alu_input_b_r  = U_imm_r;
  end else
  if (branch_r) begin:PC_INC
    alu_func_r     = `ALU_ADD;
    alu_input_a_r  = opcode_pc_i;
    alu_input_b_r  = 32'd4;
  end else begin
    alu_func_r     = `ALU_NONE;
    alu_input_a_r  = 32'b0;
    alu_input_b_r  = 32'b0;
  end
end

//-------------------------------------------------------------
// ALU
//-------------------------------------------------------------
wire [31:0]  alu_p_w;
biriscv_alu
u_alu
(
    .alu_op_i(alu_func_r),
    .alu_a_i(alu_input_a_r),
    .alu_b_i(alu_input_b_r),
    .alu_p_o(alu_p_w)
);

//-------------------------------------------------------------
// Flop ALU output
//-------------------------------------------------------------
reg [31:0] result_q;
always @ (posedge clk_i) if (~hold_i) result_q <= alu_p_w;

assign writeback_value_o  = result_q;

//-------------------------------------------------------------
// Execute - Branch operations
//-------------------------------------------------------------
reg        branch_r;
reg        branch_taken_r;
reg [31:0] branch_target_r;
reg        branch_call_r;
reg        branch_ret_r;
reg        branch_jmp_r;

wire BEQ  = opcode_ra_operand_i == opcode_rb_operand_i;
wire BLTU = opcode_ra_operand_i  < opcode_rb_operand_i;
wire BLT  = opcode_ra_operand_i  < opcode_rb_operand_i & opcode_ra_operand_i[31] == opcode_rb_operand_i[31]
                                                       | opcode_ra_operand_i[31] & ~opcode_rb_operand_i[31];

always @* begin
  branch_r        = 1'b1;
  branch_taken_r  = 1'b0;
  branch_call_r   = 1'b0;
  branch_ret_r    = 1'b0;
  branch_jmp_r    = 1'b0;

  // Default branch_r target is relative to current PC
  branch_target_r = opcode_pc_i + B_imm_r;

  if ((opcode_opcode_i & `INST_JAL_MASK) == `INST_JAL) begin:JAL
    branch_taken_r  = 1'b1;
    branch_target_r = opcode_pc_i + J_imm_r;
    branch_call_r   = (opcode_rd_idx_i == 5'd1); // RA
    branch_jmp_r    = 1'b1;
  end else
  if ((opcode_opcode_i & `INST_JALR_MASK) == `INST_JALR) begin:JALR
    branch_taken_r      = 1'b1;
    branch_target_r     = opcode_ra_operand_i + I_imm_r;
    branch_target_r[0]  = 1'b0;
    branch_ret_r        = (opcode_ra_idx_i == 5'd1 && I_imm_r[11:0] == 12'b0); // RA
    branch_call_r       = ~branch_ret_r && (opcode_rd_idx_i == 5'd1); // RA
    branch_jmp_r        = ~(branch_call_r | branch_ret_r);
  end else
  if ((opcode_opcode_i & `INST_BEQ_MASK ) == `INST_BEQ ) branch_taken_r=  BEQ ; else
  if ((opcode_opcode_i & `INST_BNE_MASK ) == `INST_BNE ) branch_taken_r= ~BEQ ; else
  if ((opcode_opcode_i & `INST_BLT_MASK ) == `INST_BLT ) branch_taken_r=  BLT ; else
  if ((opcode_opcode_i & `INST_BGE_MASK ) == `INST_BGE ) branch_taken_r= ~BLT ; else
  if ((opcode_opcode_i & `INST_BLTU_MASK) == `INST_BLTU) branch_taken_r=  BLTU; else
  if ((opcode_opcode_i & `INST_BGEU_MASK) == `INST_BGEU) branch_taken_r= ~BLTU; else
                                                         branch_r      =  1'b0;
end

reg        branch_taken_q;
reg        branch_ntaken_q;
reg [31:0] pc_x_q;
reg [31:0] pc_m_q;
reg        branch_call_q;
reg        branch_ret_q;
reg        branch_jmp_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) begin
  branch_taken_q   <= 1'b0;
  branch_ntaken_q  <= 1'b0;
  branch_call_q    <= 1'b0;
  branch_ret_q     <= 1'b0;
  branch_jmp_q     <= 1'b0;
end else
if (opcode_valid_i) begin
  branch_taken_q   <= branch_r &  branch_taken_r;
  branch_ntaken_q  <= branch_r & ~branch_taken_r;
  branch_call_q    <= branch_r &  branch_call_r;
  branch_ret_q     <= branch_r &  branch_ret_r;
  branch_jmp_q     <= branch_r &  branch_jmp_r;
end
always @ (posedge clk_i) if (opcode_valid_i) pc_x_q <= branch_taken_r ? branch_target_r : alu_p_w;
always @ (posedge clk_i) if (opcode_valid_i) pc_m_q <= opcode_pc_i;

assign branch_request_o      = branch_taken_q | branch_ntaken_q;
assign branch_is_taken_o     = branch_taken_q;
assign branch_is_not_taken_o = branch_ntaken_q;
assign branch_source_o       = pc_m_q;
assign branch_pc_o           = pc_x_q;
assign branch_is_call_o      = branch_call_q;
assign branch_is_ret_o       = branch_ret_q;
assign branch_is_jmp_o       = branch_jmp_q;

assign branch_d_request_o = branch_r & opcode_valid_i & branch_taken_r;
assign branch_d_pc_o      = branch_target_r;
assign branch_d_priv_o    = 2'b0; // don't care

endmodule
