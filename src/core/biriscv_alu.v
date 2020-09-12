module biriscv_alu
(
     input  [  3:0]  alu_op_i
    ,input  [ 31:0]  alu_a_i
    ,input  [ 31:0]  alu_b_i

    ,output [ 31:0]  alu_p_o
);

`include "biriscv_defs_alu.v"

wire rsh_sign = alu_op_i == `ALU_SHIFTR_ARITH & alu_a_i[31];// Arithmetic shift? Fill with 1's if MSB set

wire [31:0] rsh [5:0], lsh [5:0];

assign rsh[0] = alu_a_i;
assign lsh[0] = alu_a_i;

genvar G_I;
generate
  for (G_I=0;G_I<5;G_I=G_I+1) begin:sh_genblock
    assign rsh[G_I+1] = alu_b_i[G_I] ? {{(1<<G_I){rsh_sign}}, rsh[G_I][31         :(1<<G_I)]}                   : rsh[G_I];
    assign lsh[G_I+1] = alu_b_i[G_I] ? {                      lsh[G_I][31-(1<<G_I): 0      ], {(1<<G_I){1'b0}}} : lsh[G_I];
  end
endgenerate

reg  [31:0] result_r;
always @(alu_op_i or alu_a_i or alu_b_i or rsh[5] or lsh[5])
  case (alu_op_i)
      `ALU_SHIFTR_ARITH     ,
      `ALU_SHIFTR           : result_r = rsh[5];
      `ALU_SHIFTL           : result_r = lsh[5];
      `ALU_ADD              : result_r = alu_a_i + alu_b_i;
      `ALU_SUB              : result_r = alu_a_i - alu_b_i;
      `ALU_AND              : result_r = alu_a_i & alu_b_i;
      `ALU_OR               : result_r = alu_a_i | alu_b_i;
      `ALU_XOR              : result_r = alu_a_i ^ alu_b_i;
      `ALU_LESS_THAN        : result_r = alu_a_i < alu_b_i;
      `ALU_LESS_THAN_SIGNED : result_r = alu_a_i < alu_b_i & alu_a_i[31] == alu_b_i[31]
                                                           | alu_a_i[31] & ~alu_b_i[31];
      default               : result_r = alu_a_i;
  endcase

assign alu_p_o = result_r;

endmodule
