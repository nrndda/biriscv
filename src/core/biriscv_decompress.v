module biriscv_decompress
(
   input  [15:0]   compressed_i
  ,output [31:0] decompressed_o
  ,output               valid_o

);
`include "biriscv_defs_rv32i.v"
`include "biriscv_defs_rv32c.v"

reg [31:0] decompressed;


`define RS2C  {1'b1,compressed_i[ 4:2]}
`define RS2         compressed_i[ 6:2]
`define RS1C  {1'b1,compressed_i[ 9:7]}
`define RD          compressed_i[11:7]

`define X0    5'h0
`define X1    5'h1
`define SP    5'h2

`define RD_POS      7
`define RS1_POS    15
`define RS2_POS    20
`define IMM12_POS  20
`define IMM12_POS1 25
`define IMM20_POS  12

wire [ 7:2] IMM12_CLWSP; assign {IMM12_CLWSP[5],IMM12_CLWSP[4:2],IMM12_CLWSP[7:6]} = {compressed_i[12],compressed_i[6:2]};
wire [31:0] IMM12_LWSP = {4'h0,IMM12_CLWSP,2'h0} << `IMM12_POS;

wire [ 7:2] IMM12_CSWSP; assign {IMM12_CSWSP[5:2],IMM12_CSWSP[7:6]} = compressed_i[12:7];
wire [31:0] IMM12_SWSP = {4'h0,IMM12_CSWSP[7:5]     } << `IMM12_POS1|
                         {     IMM12_CSWSP[4:2],2'h0} << `RD_POS;

wire [ 6:2] IMM12_CLW; assign {IMM12_CLW[5:3],IMM12_CLW[2],IMM12_CLW[6]} = {compressed_i[12:10],compressed_i[6:5]};
wire [31:0] IMM12_LW = {5'h0,IMM12_LW,2'h0} << `IMM12_POS;

wire [11:1] IMM20_CJ; assign {IMM20_CJ[11],IMM20_CJ[4],IMM20_CJ[9:8],IMM20_CJ[10],IMM20_CJ[6],IMM20_CJ[7],IMM20_CJ[3:1],IMM20_CJ[5]} = compressed_i[12:2];
wire [20:1] IMM20_CJ_se = {{9{IMM20_CJ[11]}},IMM20_CJ};
wire [31:0] IMM20_J = {IMM20_CJ_se[20],IMM20_CJ_se[10:1],IMM20_CJ_se[11],IMM20_CJ_se[19:12]} << `IMM20_POS;

wire [ 8:1] IMM12_CBEQ; assign {IMM12_CBEQ[8],IMM12_CBEQ[4:3],IMM12_CBEQ[7:6],IMM12_CBEQ[2:1],IMM12_CBEQ[5]} = {compressed_i[12:10],compressed_i[6:2]};
wire [12:1] IMM20_CBEQ_se = {{4{IMM12_CBEQ[8]}},IMM12_CBEQ};
wire [31:0] IMM12_BEQ = {IMM20_CBEQ_se[ 12],IMM20_CBEQ_se[10:5]} << `IMM12_POS1|
                        {IMM20_CBEQ_se[4:1],IMM20_CBEQ_se[11  ]} << `RD_POS;

assign decompressed_o = (                                                      /*OPcode*/   /*Data register*/  /*Address register*/  /*Imm*/
                          ((compressed_i & `INST_CLWSP_MASK) == `INST_CLWSP) ? `INST_LW   | `RD               | `SP   << `RD_POS  | IMM12_LWSP: //TODO RD !=0
                          ((compressed_i & `INST_CSWSP_MASK) == `INST_CSWSP) ? `INST_SW   | `RS2  << `RS2_POS | `SP   << `RS1_POS | IMM12_SWSP:
                          ((compressed_i & `INST_CLW_MASK  ) == `INST_CLW  ) ? `INST_LW   | `RS2C << `RD_POS  | `RS1C << `RS1_POS | IMM12_LW  :
                          ((compressed_i & `INST_CSW_MASK  ) == `INST_CSW  ) ? `INST_SW   | `RS2C << `RS2_POS | `RS1C << `RS1_POS | IMM12_LW  : //NOTE IMM12 the same
                          ((compressed_i & `INST_CJ_MASK   ) == `INST_CJ   ) ? `INST_JAL                      | `X0   << `RD_POS  | IMM20_J   :
                          ((compressed_i & `INST_CJAL_MASK ) == `INST_CJAL ) ? `INST_JAL                      | `X1   << `RD_POS  | IMM20_J   : //NOTE IMM20 the same
                          ((compressed_i & `INST_CJR_MASK  ) == `INST_CJR  ) ? `INST_JALR | `RD   << `RS1_POS | `X0   << `RD_POS              : //TODO rs1 !=0 rs2 = 0
                          ((compressed_i & `INST_CJALR_MASK) == `INST_CJALR) ? `INST_JALR | `RD   << `RS1_POS | `X1   << `RD_POS              : //TODO rs1 !=0 rs2 = 0
                          ((compressed_i & `INST_CBEQZ_MASK) == `INST_CBEQZ) ? `INST_BEQ  | `X0   << `RS2_POS | `RS1C << `RS1_POS | IMM12_BEQ :
                          ((compressed_i & `INST_CBNEZ_MASK) == `INST_CBNEZ) ? `INST_BNE  | `X0   << `RS2_POS | `RS1C << `RS1_POS | IMM12_BEQ : //NOTE IMM12 the same
                         {16{1'b0}}
);


endmodule
