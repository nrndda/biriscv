
`define INST_WFI         32'h10500073
`define INST_WFI_MASK    32'hffff8fff

`define INST_FENCE       32'h0000000f
`define INST_FENCE_MASK  `MASK_I_TYPE

`define INST_SFENCE      32'h12000073
`define INST_SFENCE_MASK 32'hfe007fff

`define INST_IFENCE      32'h0000100f
`define INST_IFENCE_MASK `MASK_I_TYPE

