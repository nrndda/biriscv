
`define MASK_CR_TYPE        16'hf003
`define MASK_CB_TYPE        16'he003
`define MASK_CJ_TYPE        16'he003
`define MASK_CJJ_TYPE       16'hf07f
`define MASK_CL_TYPE        16'he003
`define MASK_CA_TYPE        16'hfc03
`define MASK_CAI_TYPE       16'hec03
`define MASK_CAA_TYPE       16'hfc63
`define MASK_CI_TYPE        16'he003
`define MASK_CIW_TYPE       16'he003
`define MASK_CS_TYPE        16'he003
`define MASK_CSS_TYPE       16'he003


`define INST_CEBREAK        16'h9002
`define INST_CEBREAK_MASK   16'hffff

`define INST_CLW            16'h4000
`define INST_CLW_MASK       `MASK_CL_TYPE

`define INST_CLWSP          16'h4002
`define INST_CLWSP_MASK     `MASK_CI_TYPE

`define INST_CSW            16'hc000
`define INST_CSW_MASK       `MASK_CS_TYPE

`define INST_CSWSP          16'hc002
`define INST_CSWSP_MASK     `MASK_CSS_TYPE

`define INST_CJ             16'ha001
`define INST_CJ_MASK        `MASK_CJ_TYPE

`define INST_CJR            16'h8002
`define INST_CJR_MASK       `MASK_CJJ_TYPE

`define INST_CJAL           16'h2001
`define INST_CJAL_MASK      `MASK_CJ_TYPE

`define INST_CJALR          16'h9002
`define INST_CJALR_MASK     `MASK_CJJ_TYPE

`define INST_CBEQZ          16'hc001
`define INST_CBEQZ_MASK     `MASK_CB_TYPE

`define INST_CBNEZ          16'he001
`define INST_CBNEZ_MASK     `MASK_CB_TYPE

`define INST_CLI            16'h4001
`define INST_CLI_MASK       `MASK_CI_TYPE

`define INST_CLUI           16'h6001
`define INST_CLUI_MASK      `MASK_CI_TYPE

`define INST_CMV            16'h8002
`define INST_CMV_MASK       `MASK_CR_TYPE

`define INST_CADD           16'h9002
`define INST_CADD_MASK      `MASK_CR_TYPE

`define INST_CADDI          16'h0001
`define INST_CADDI_MASK     `MASK_CI_TYPE

`define INST_CADDI16sp      16'h6101
`define INST_CADDI16sp_MASK 16'hef83

`define INST_CADDI4spn      16'h0000
`define INST_CADDI4spn_MASK `MASK_CIW_TYPE

`define INST_CSUB           16'h8c01
`define INST_CSUB_MASK      `MASK_CS_TYPE

`define INST_CSLLI          16'h0002
`define INST_CSLLI_MASK     `MASK_CI_TYPE

`define INST_CSRLI          16'h8001
`define INST_CSRLI_MASK     `MASK_CAI_TYPE

`define INST_CSRAI          16'h8401
`define INST_CSRAI_MASK     `MASK_CAI_TYPE

`define INST_CAND           16'h8c61
`define INST_CAND_MASK      `MASK_CAA_TYPE

`define INST_CANDI          16'h8801
`define INST_CANDI_MASK     `MASK_CAI_TYPE

`define INST_COR            16'h8c41
`define INST_COR_MASK       `MASK_CAA_TYPE

`define INST_CXOR           16'h8c21
`define INST_CXOR_MASK      `MASK_CAA_TYPE

