
`define MASK_R_TYPE      32'hFE00707F
`define MASK_I_TYPE      32'h0000707F
`define MASK_S_TYPE      32'h0000707F
`define MASK_B_TYPE      32'h0000707F
`define MASK_U_TYPE      32'h0000007F
`define MASK_J_TYPE      32'h0000007F
`define MASK_FULL        32'hFFFFFFFF


`define INST_ANDI        32'h7013
`define INST_ANDI_MASK   `MASK_I_TYPE

`define INST_ADDI        32'h13
`define INST_ADDI_MASK   `MASK_I_TYPE

`define INST_SLTI        32'h2013
`define INST_SLTI_MASK   `MASK_I_TYPE

`define INST_SLTIU       32'h3013
`define INST_SLTIU_MASK  `MASK_I_TYPE

`define INST_ORI         32'h6013
`define INST_ORI_MASK    `MASK_I_TYPE

`define INST_XORI        32'h4013
`define INST_XORI_MASK   `MASK_I_TYPE

`define INST_SLLI        32'h1013
`define INST_SLLI_MASK   `MASK_R_TYPE

`define INST_SRLI        32'h5013
`define INST_SRLI_MASK   `MASK_R_TYPE

`define INST_SRAI        32'h40005013
`define INST_SRAI_MASK   `MASK_R_TYPE

`define INST_LUI         32'h37
`define INST_LUI_MASK    `MASK_U_TYPE

`define INST_AUIPC       32'h17
`define INST_AUIPC_MASK  `MASK_U_TYPE

`define INST_ADD         32'h33
`define INST_ADD_MASK    `MASK_R_TYPE

`define INST_SUB         32'h40000033
`define INST_SUB_MASK    `MASK_R_TYPE

`define INST_SLT         32'h2033
`define INST_SLT_MASK    `MASK_R_TYPE

`define INST_SLTU        32'h3033
`define INST_SLTU_MASK   `MASK_R_TYPE

`define INST_XOR         32'h4033
`define INST_XOR_MASK    `MASK_R_TYPE

`define INST_OR          32'h6033
`define INST_OR_MASK     `MASK_R_TYPE

`define INST_AND         32'h7033
`define INST_AND_MASK    `MASK_R_TYPE

`define INST_SLL         32'h1033
`define INST_SLL_MASK    `MASK_R_TYPE

`define INST_SRL         32'h5033
`define INST_SRL_MASK    `MASK_R_TYPE

`define INST_SRA         32'h40005033
`define INST_SRA_MASK    `MASK_R_TYPE

`define INST_JAL         32'h6f
`define INST_JAL_MASK    `MASK_J_TYPE

`define INST_JALR        32'h67
`define INST_JALR_MASK   `MASK_I_TYPE

`define INST_BEQ         32'h63
`define INST_BEQ_MASK    `MASK_B_TYPE

`define INST_BNE         32'h1063
`define INST_BNE_MASK    `MASK_B_TYPE

`define INST_BLT         32'h4063
`define INST_BLT_MASK    `MASK_B_TYPE

`define INST_BGE         32'h5063
`define INST_BGE_MASK    `MASK_B_TYPE

`define INST_BLTU        32'h6063
`define INST_BLTU_MASK   `MASK_B_TYPE

`define INST_BGEU        32'h7063
`define INST_BGEU_MASK   `MASK_B_TYPE

`define INST_LB          32'h3
`define INST_LB_MASK     `MASK_I_TYPE

`define INST_LH          32'h1003
`define INST_LH_MASK     `MASK_I_TYPE

`define INST_LW          32'h2003
`define INST_LW_MASK     `MASK_I_TYPE

`define INST_LBU         32'h4003
`define INST_LBU_MASK    `MASK_I_TYPE

`define INST_LHU         32'h5003
`define INST_LHU_MASK    `MASK_I_TYPE

`define INST_LWU         32'h6003
`define INST_LWU_MASK    `MASK_I_TYPE

`define INST_SB          32'h23
`define INST_SB_MASK      `MASK_B_TYPE

`define INST_SH          32'h1023
`define INST_SH_MASK      `MASK_B_TYPE

`define INST_SW          32'h2023
`define INST_SW_MASK      `MASK_B_TYPE

`define INST_ECALL       32'h73
`define INST_ECALL_MASK  `MASK_FULL

`define INST_EBREAK      32'h100073
`define INST_EBREAK_MASK `MASK_FULL

`define INST_MRET        32'h10200073
`define INST_MRET_MASK   32'hdfffffff
`define INST_MRET_R         29
