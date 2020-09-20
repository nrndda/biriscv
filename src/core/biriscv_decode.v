module biriscv_decode
#(
  parameter PN_DEC_QUEUE_LOG = 1
)
(
   input           clk_i
  ,input           rst_i
  ,input           fetch_in_valid_i
  ,input  [ 63:0]  fetch_in_instr_i
  ,input  [  1:0]  fetch_in_pred_branch_i
  ,input           fetch_in_fault_fetch_i
  ,input           fetch_in_fault_page_i
  ,input  [ 31:0]  fetch_in_pc_i
  ,input           fetch_out0_accept_i
  ,input           fetch_out1_accept_i
  ,input           branch_request_i

  ,output          fetch_in_accept_o
  ,output          fetch_out0_valid_o
  ,output [ 31:0]  fetch_out0_instr_o
  ,output [ 31:0]  fetch_out0_pc_o
  ,output          fetch_out0_fault_fetch_o
  ,output          fetch_out0_fault_page_o
  ,output          fetch_out0_instr_exec_o
  ,output          fetch_out0_instr_lsu_o
  ,output          fetch_out0_instr_branch_o
  ,output          fetch_out0_instr_mul_o
  ,output          fetch_out0_instr_div_o
  ,output          fetch_out0_instr_csr_o
  ,output          fetch_out0_instr_rd_valid_o
  ,output          fetch_out0_instr_invalid_o
  ,output          fetch_out1_valid_o
  ,output [ 31:0]  fetch_out1_instr_o
  ,output [ 31:0]  fetch_out1_pc_o
  ,output          fetch_out1_fault_fetch_o
  ,output          fetch_out1_fault_page_o
  ,output          fetch_out1_instr_exec_o
  ,output          fetch_out1_instr_lsu_o
  ,output          fetch_out1_instr_branch_o
  ,output          fetch_out1_instr_mul_o
  ,output          fetch_out1_instr_div_o
  ,output          fetch_out1_instr_csr_o
  ,output          fetch_out1_instr_rd_valid_o
  ,output          fetch_out1_instr_invalid_o
);

localparam PN_DEC_QUEUE = 1 << PN_DEC_QUEUE_LOG;

reg  [ 2-1:0] instr_info [PN_DEC_QUEUE-1:0];
reg  [32-1:0] instr_pc   [PN_DEC_QUEUE-1:0];
reg  [16-1:0] instr_buf  [PN_DEC_QUEUE-1:0][4-1:0];
reg  [ 4-1:0] instr_valid[PN_DEC_QUEUE-1:0];


reg  [PN_DEC_QUEUE_LOG  -1:0] wr_ptr;
reg  [PN_DEC_QUEUE_LOG+2-1:0] rd_ptr0 [3:0];
wire [PN_DEC_QUEUE_LOG+2-1:0] rd_ptr00, rd_ptr01;
wire [PN_DEC_QUEUE_LOG+2-1:0] rd_ptr10, rd_ptr11;
wire [PN_DEC_QUEUE      -1:0] any_valid;

wire                 compressed0,         compressed1;
wire [16-1:0] instr2decompress0 , instr2decompress1  ;
wire [32-1:0]      decompressed0,       decompressed1;

wire write  = fetch_in_valid_i   & fetch_in_accept_o;
wire fetch0 = fetch_out0_valid_o & fetch_out0_accept_i;
wire fetch1 = fetch_out1_valid_o & fetch_out1_accept_i;

assign fetch_in_accept_o = ~|instr_valid[wr_ptr];

always @ (posedge clk_i or posedge rst_i) if (rst_i) wr_ptr <= 0; else if (write) wr_ptr <= wr_ptr + 1;

genvar G_I;
generate
  for (G_I=0;G_I<4;G_I=G_I+1) begin:RD_PTR_GEN
    always @ (posedge clk_i or posedge rst_i)
      if ( rst_i                                      ) rd_ptr0[G_I] <=              0 + G_I[1:0]; else //NOTE Duplicate read pointer for synthesis worst path reducing
      if ( branch_request_i                           ) rd_ptr0[G_I] <={wr_ptr,2'h0}   + G_I[1:0]; else
      if ( fetch0 & compressed0 & fetch1 & compressed1) rd_ptr0[G_I] <= rd_ptr0[0] + 2 + G_I[1:0]; else
      if ( fetch0 & compressed0 & fetch1              ) rd_ptr0[G_I] <= rd_ptr0[0] + 3 + G_I[1:0]; else
      if ( fetch0               & fetch1 & compressed1) rd_ptr0[G_I] <= rd_ptr0[0] + 3 + G_I[1:0]; else
      if ( fetch0               & fetch1              ) rd_ptr0[G_I] <= rd_ptr0[0] + 4 + G_I[1:0]; else
      if ( fetch0 & compressed0                       ) rd_ptr0[G_I] <= rd_ptr0[0] + 1 + G_I[1:0]; else
      if ( fetch0                                     ) rd_ptr0[G_I] <= rd_ptr0[0] + 2 + G_I[1:0]; else
      if (~fetch_out0_valid_o   & |any_valid          ) rd_ptr0[G_I] <= rd_ptr0[0] + 1 + G_I[1:0];      //NOTE When written with fetch_in_pred_branch_i[0] there will be empty word
  end
endgenerate

assign rd_ptr00 =                             rd_ptr0[0];
assign rd_ptr01 =                             rd_ptr0[1];
assign rd_ptr10 = compressed0 ? rd_ptr01    : rd_ptr0[2];
assign rd_ptr11 = compressed0 ? rd_ptr0 [2] : rd_ptr0[3];

genvar G_D, G_H;
generate
  for (G_D=0;G_D<PN_DEC_QUEUE;G_D=G_D+1) begin:I64bit_BUF_GEN
    for (G_H=0;G_H<4;G_H=G_H+1) begin:I16bit_BUF_GEN
      assign any_valid[G_D] = |instr_valid[G_D];
      always @ (posedge clk_i or posedge rst_i)
        if (rst_i                                                                         ) instr_valid[G_D][G_H] <= 0; else
        if (write                 & (wr_ptr   ==  G_D[PN_DEC_QUEUE_LOG-1:0]) & ~G_H[  1]  ) instr_valid[G_D][G_H] <= 1; else
        if (write                 & (wr_ptr   ==  G_D[PN_DEC_QUEUE_LOG-1:0]) &  G_H[  1]  ) instr_valid[G_D][G_H] <= ~fetch_in_pred_branch_i[0]; else
        if (branch_request_i                                                              ) instr_valid[G_D][G_H] <= 0; else
        if (fetch0                & (rd_ptr00 == {G_D[PN_DEC_QUEUE_LOG-1:0],    G_H[1:0]})) instr_valid[G_D][G_H] <= 0; else
        if (fetch0 & ~compressed0 & (rd_ptr01 == {G_D[PN_DEC_QUEUE_LOG-1:0],    G_H[1:0]})) instr_valid[G_D][G_H] <= 0; else
        if (fetch1                & (rd_ptr10 == {G_D[PN_DEC_QUEUE_LOG-1:0],    G_H[1:0]})) instr_valid[G_D][G_H] <= 0; else
        if (fetch1 & ~compressed1 & (rd_ptr11 == {G_D[PN_DEC_QUEUE_LOG-1:0],    G_H[1:0]})) instr_valid[G_D][G_H] <= 0;
      always @ (posedge clk_i)
        if (write                 & (wr_ptr   ==  G_D[PN_DEC_QUEUE_LOG-1:0])              ) instr_buf  [G_D][G_H] <= fetch_in_instr_i[16*(G_H+1)-1:16*G_H];
    end
    always @ (posedge clk_i)
        if (write                 & (wr_ptr   ==  G_D[PN_DEC_QUEUE_LOG-1:0])              ) instr_info [G_D]      <={fetch_in_fault_page_i, fetch_in_fault_fetch_i};
    always @ (posedge clk_i)
        if (write                 & (wr_ptr   ==  G_D[PN_DEC_QUEUE_LOG-1:0])              ) instr_pc   [G_D]      <= fetch_in_pc_i;
  end
endgenerate

assign       compressed0  = ~&instr2decompress0[1:0];
assign       compressed1  = ~&instr2decompress1[1:0];

assign instr2decompress0  =                                                                      instr_buf  [rd_ptr00[2]]      [rd_ptr00[1:0]];
assign instr2decompress1  =                                                                      instr_buf  [rd_ptr10[2]]      [rd_ptr10[1:0]];

assign fetch_out0_instr_o = compressed0 ? decompressed0 : {instr_buf[rd_ptr01[2]][rd_ptr01[1:0]],instr_buf  [rd_ptr00[2]]      [rd_ptr00[1:0]]};
assign fetch_out1_instr_o = compressed1 ? decompressed1 : {instr_buf[rd_ptr11[2]][rd_ptr11[1:0]],instr_buf  [rd_ptr10[2]]      [rd_ptr10[1:0]]};

assign fetch_out0_valid_o =                                                                      instr_valid[rd_ptr00[2]]      [rd_ptr00[1:0]];
assign fetch_out1_valid_o =                                                                      instr_valid[rd_ptr10[2]]      [rd_ptr10[1:0]];

assign {fetch_out0_fault_page_o, fetch_out0_fault_fetch_o} =                                     instr_info [rd_ptr00[2]];
assign {fetch_out1_fault_page_o, fetch_out1_fault_fetch_o} =                                     instr_info [rd_ptr10[2]];

assign fetch_out0_pc_o =                                                                        {instr_pc   [rd_ptr00[2]][31:3],rd_ptr00[1:0],1'b0};
assign fetch_out1_pc_o =                                                                        {instr_pc   [rd_ptr10[2]][31:3],rd_ptr10[1:0],1'b0};

biriscv_decompress
u_dervc0
(
     .  compressed_i(instr2decompress0)
    ,.decompressed_o(    decompressed0)
);

biriscv_decompress
u_dervc1
(
     .  compressed_i(instr2decompress1)
    ,.decompressed_o(    decompressed1)
);

biriscv_decoder
u_dec0
(
     .valid_i(fetch_out0_valid_o)
    ,.fetch_fault_i(fetch_out0_fault_fetch_o | fetch_out0_fault_page_o)
    ,.opcode_i(fetch_out0_instr_o)

    ,.invalid_o(fetch_out0_instr_invalid_o)
    ,.exec_o(fetch_out0_instr_exec_o)
    ,.lsu_o(fetch_out0_instr_lsu_o)
    ,.branch_o(fetch_out0_instr_branch_o)
    ,.mul_o(fetch_out0_instr_mul_o)
    ,.div_o(fetch_out0_instr_div_o)
    ,.csr_o(fetch_out0_instr_csr_o)
    ,.rd_valid_o(fetch_out0_instr_rd_valid_o)
);

biriscv_decoder
u_dec1
(
      .valid_i(fetch_out1_valid_o)
    ,.fetch_fault_i(fetch_out1_fault_fetch_o | fetch_out1_fault_page_o)
    ,.opcode_i(fetch_out1_instr_o)

    ,.invalid_o(fetch_out1_instr_invalid_o)
    ,.exec_o(fetch_out1_instr_exec_o)
    ,.lsu_o(fetch_out1_instr_lsu_o)
    ,.branch_o(fetch_out1_instr_branch_o)
    ,.mul_o(fetch_out1_instr_mul_o)
    ,.div_o(fetch_out1_instr_div_o)
    ,.csr_o(fetch_out1_instr_csr_o)
    ,.rd_valid_o(fetch_out1_instr_rd_valid_o)
);

endmodule
