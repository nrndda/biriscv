module biriscv_multiplier
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
    ,output [ 31:0]  writeback_value_o
);

`include "biriscv_defs_dec.v"

localparam MULT_STAGES = 2; // 2 or 3

reg  [31:0]  result_e2_q;
reg  [31:0]  result_e3_q;

reg [32:0]   operand_a_e1_q;
reg [32:0]   operand_b_e1_q;
reg          mulhi_sel_e1_q;

wire [64:0]  mult_result_w;
reg  [32:0]  operand_b_r;
reg  [32:0]  operand_a_r;

wire mult_inst_w    = ((opcode_opcode_i & `INST_MUL_MASK   ) == `INST_MUL)    ||
                      ((opcode_opcode_i & `INST_MULH_MASK  ) == `INST_MULH)   ||
                      ((opcode_opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU) ||
                      ((opcode_opcode_i & `INST_MULHU_MASK ) == `INST_MULHU);


always @* if ((opcode_opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU) operand_a_r = {opcode_ra_operand_i[31], opcode_ra_operand_i[31:0]}; else
          if ((opcode_opcode_i & `INST_MULH_MASK  ) == `INST_MULH  ) operand_a_r = {opcode_ra_operand_i[31], opcode_ra_operand_i[31:0]}; else
                                                                     operand_a_r = {               1'b0    , opcode_ra_operand_i[31:0]};// MULHU || MUL

always @* if ((opcode_opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU) operand_b_r = {               1'b0    , opcode_rb_operand_i[31:0]}; else
          if ((opcode_opcode_i & `INST_MULH_MASK  ) == `INST_MULH  ) operand_b_r = {opcode_rb_operand_i[31], opcode_rb_operand_i[31:0]}; else
                                                                     operand_b_r = {               1'b0    , opcode_rb_operand_i[31:0]}; // MULHU || MUL

always @(posedge clk_i) if (opcode_valid_i & mult_inst_w & ~hold_i) begin
  operand_a_e1_q <= operand_a_r;
  operand_b_e1_q <= operand_b_r;
  mulhi_sel_e1_q <= ~((opcode_opcode_i & `INST_MUL_MASK) == `INST_MUL);
end

assign mult_result_w = {{32{operand_a_e1_q[32]}}, operand_a_e1_q}
                     * {{32{operand_b_e1_q[32]}}, operand_b_e1_q};

always @(posedge clk_i) if (~hold_i) result_e2_q <= mulhi_sel_e1_q ? mult_result_w[63:32] : mult_result_w[31:0];
always @(posedge clk_i) if (~hold_i) result_e3_q <= result_e2_q;

assign writeback_value_o  = (MULT_STAGES == 3) ? result_e3_q : result_e2_q;


endmodule
