//--------------------------------------------------------------------
// Privilege levels
//--------------------------------------------------------------------
`define PRIV_USER         2'd0
`define PRIV_SUPER        2'd1
`define PRIV_MACHINE      2'd3

//--------------------------------------------------------------------
// IRQ Numbers
//--------------------------------------------------------------------
`define IRQ_S_SOFT   1
`define IRQ_M_SOFT   3
`define IRQ_S_TIMER  5
`define IRQ_M_TIMER  7
`define IRQ_S_EXT    9
`define IRQ_M_EXT    11
`define IRQ_MIN      (`IRQ_S_SOFT)
`define IRQ_MAX      (`IRQ_M_EXT + 1)
`define IRQ_MASK     ((1 << `IRQ_M_EXT)   | (1 << `IRQ_S_EXT)   | (1 << `IRQ_M_TIMER) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_M_SOFT)  | (1 << `IRQ_S_SOFT))

`define SR_IP_MSIP_R      `IRQ_M_SOFT
`define SR_IP_MTIP_R      `IRQ_M_TIMER
`define SR_IP_MEIP_R      `IRQ_M_EXT
`define SR_IP_SSIP_R      `IRQ_S_SOFT
`define SR_IP_STIP_R      `IRQ_S_TIMER
`define SR_IP_SEIP_R      `IRQ_S_EXT

//--------------------------------------------------------------------
// CSR Registers - Simulation control
//--------------------------------------------------------------------
`define CSR_DSCRATCH       12'h7b2
`define CSR_SIM_CTRL       12'h8b2
`define CSR_SIM_CTRL_MASK  32'hFFFFFFFF
    `define CSR_SIM_CTRL_EXIT (0 << 24)
    `define CSR_SIM_CTRL_PUTC (1 << 24)

//--------------------------------------------------------------------
// CSR Registers
//--------------------------------------------------------------------
`define CSR_MSTATUS       12'h300
`define CSR_MSTATUS_MASK  32'hFFFFFFFF
`define CSR_MISA          12'h301
`define CSR_MISA_MASK     32'hFFFFFFFF
    `define MISA_RV32     32'h40000000
    `define MISA_RVI      32'h00000100
    `define MISA_RVE      32'h00000010
    `define MISA_RVM      32'h00001000
    `define MISA_RVA      32'h00000001
    `define MISA_RVF      32'h00000020
    `define MISA_RVD      32'h00000008
    `define MISA_RVC      32'h00000004
    `define MISA_RVS      32'h00040000
    `define MISA_RVU      32'h00100000
`define CSR_MEDELEG       12'h302
`define CSR_MEDELEG_MASK  32'h0000FFFF
`define CSR_MIDELEG       12'h303
`define CSR_MIDELEG_MASK  32'h0000FFFF
`define CSR_MIE           12'h304
`define CSR_MIE_MASK      `IRQ_MASK
`define CSR_MTVEC         12'h305
`define CSR_MTVEC_MASK    32'hFFFFFFFF
`define CSR_MSCRATCH      12'h340
`define CSR_MSCRATCH_MASK 32'hFFFFFFFF
`define CSR_MEPC          12'h341
`define CSR_MEPC_MASK     32'hFFFFFFFF
`define CSR_MCAUSE        12'h342
`define CSR_MCAUSE_MASK   32'h8000000F
`define CSR_MTVAL         12'h343
`define CSR_MTVAL_MASK    32'hFFFFFFFF
`define CSR_MIP           12'h344
`define CSR_MIP_MASK      `IRQ_MASK
`define CSR_MCYCLE        12'hc00
`define CSR_MCYCLE_MASK   32'hFFFFFFFF
`define CSR_MTIME         12'hc01
`define CSR_MTIME_MASK    32'hFFFFFFFF
`define CSR_MTIMEH        12'hc81
`define CSR_MTIMEH_MASK   32'hFFFFFFFF
`define CSR_MHARTID       12'hF14
`define CSR_MHARTID_MASK  32'hFFFFFFFF

// Non-std
`define CSR_MTIMECMP        12'h7c0
`define CSR_MTIMECMP_MASK   32'hFFFFFFFF

//-----------------------------------------------------------------
// CSR Registers - Supervisor
//-----------------------------------------------------------------
`define CSR_SSTATUS       12'h100
`define CSR_SSTATUS_MASK  `SR_SMODE_MASK
`define CSR_SIE           12'h104
`define CSR_SIE_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_STVEC         12'h105
`define CSR_STVEC_MASK    32'hFFFFFFFF
`define CSR_SSCRATCH      12'h140
`define CSR_SSCRATCH_MASK 32'hFFFFFFFF
`define CSR_SEPC          12'h141
`define CSR_SEPC_MASK     32'hFFFFFFFF
`define CSR_SCAUSE        12'h142
`define CSR_SCAUSE_MASK   32'h8000000F
`define CSR_STVAL         12'h143
`define CSR_STVAL_MASK    32'hFFFFFFFF
`define CSR_SIP           12'h144
`define CSR_SIP_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_SATP          12'h180
`define CSR_SATP_MASK     32'hFFFFFFFF

//--------------------------------------------------------------------
// CSR Registers - DCACHE control
//--------------------------------------------------------------------
`define CSR_DFLUSH            12'h3a0 // pmpcfg0
`define CSR_DFLUSH_MASK       32'hFFFFFFFF
`define CSR_DWRITEBACK        12'h3a1 // pmpcfg1
`define CSR_DWRITEBACK_MASK   32'hFFFFFFFF
`define CSR_DINVALIDATE       12'h3a2 // pmpcfg2
`define CSR_DINVALIDATE_MASK  32'hFFFFFFFF

//--------------------------------------------------------------------
// Status Register
//--------------------------------------------------------------------
`define SR_UIE         (1 << 0)
`define SR_UIE_R       0
`define SR_SIE         (1 << 1)
`define SR_SIE_R       1
`define SR_MIE         (1 << 3)
`define SR_MIE_R       3
`define SR_UPIE        (1 << 4)
`define SR_UPIE_R      4
`define SR_SPIE        (1 << 5)
`define SR_SPIE_R      5
`define SR_MPIE        (1 << 7)
`define SR_MPIE_R      7
`define SR_SPP         (1 << 8)
`define SR_SPP_R       8

`define SR_MPP_SHIFT   11
`define SR_MPP_MASK    2'h3
`define SR_MPP_R       12:11
`define SR_MPP_U       `PRIV_USER
`define SR_MPP_S       `PRIV_SUPER
`define SR_MPP_M       `PRIV_MACHINE

`define SR_SUM_R        18
`define SR_SUM          (1 << `SR_SUM_R)

`define SR_MPRV_R       17
`define SR_MPRV         (1 << `SR_MPRV_R)

`define SR_MXR_R        19
`define SR_MXR          (1 << `SR_MXR_R)

`define SR_SMODE_MASK   (`SR_UIE | `SR_SIE | `SR_UPIE | `SR_SPIE | `SR_SPP | `SR_SUM)

//--------------------------------------------------------------------
// SATP definitions
//--------------------------------------------------------------------
`define SATP_PPN_R        19:0 // TODO: Should be 21??
`define SATP_ASID_R       30:22
`define SATP_MODE_R       31

//--------------------------------------------------------------------
// MMU Defs (SV32)
//--------------------------------------------------------------------
`define MMU_LEVELS        2
`define MMU_PTIDXBITS     10
`define MMU_PTESIZE       4
`define MMU_PGSHIFT       (`MMU_PTIDXBITS + 2)
`define MMU_PGSIZE        (1 << `MMU_PGSHIFT)
`define MMU_VPN_BITS      (`MMU_PTIDXBITS * `MMU_LEVELS)
`define MMU_PPN_BITS      (32 - `MMU_PGSHIFT)
`define MMU_VA_BITS       (`MMU_VPN_BITS + `MMU_PGSHIFT)

`define PAGE_PRESENT      0
`define PAGE_READ         1
`define PAGE_WRITE        2
`define PAGE_EXEC         3
`define PAGE_USER         4
`define PAGE_GLOBAL       5
`define PAGE_ACCESSED     6
`define PAGE_DIRTY        7
`define PAGE_SOFT         9:8

`define PAGE_FLAGS       10'h3FF

`define PAGE_PFN_SHIFT   10
`define PAGE_SIZE        4096

//--------------------------------------------------------------------
// Exception Causes
//--------------------------------------------------------------------
`define EXCEPTION_W                        6
`define EXCEPTION_MISALIGNED_FETCH         6'h10
`define EXCEPTION_FAULT_FETCH              6'h11
`define EXCEPTION_ILLEGAL_INSTRUCTION      6'h12
`define EXCEPTION_BREAKPOINT               6'h13
`define EXCEPTION_MISALIGNED_LOAD          6'h14
`define EXCEPTION_FAULT_LOAD               6'h15
`define EXCEPTION_MISALIGNED_STORE         6'h16
`define EXCEPTION_FAULT_STORE              6'h17
`define EXCEPTION_ECALL                    6'h18
`define EXCEPTION_ECALL_U                  6'h18
`define EXCEPTION_ECALL_S                  6'h19
`define EXCEPTION_ECALL_H                  6'h1a
`define EXCEPTION_ECALL_M                  6'h1b
`define EXCEPTION_PAGE_FAULT_INST          6'h1c
`define EXCEPTION_PAGE_FAULT_LOAD          6'h1d
`define EXCEPTION_PAGE_FAULT_STORE         6'h1f
`define EXCEPTION_EXCEPTION                6'h10
`define EXCEPTION_INTERRUPT                6'h20
`define EXCEPTION_ERET                     6'h30
`define EXCEPTION_FENCE                    6'h31
`define EXCEPTION_TYPE_MASK                6'h30
`define EXCEPTION_SUBTYPE_R                3:0

`define MCAUSE_INT                      31
`define MCAUSE_MISALIGNED_FETCH         ((0 << `MCAUSE_INT) | 0)
`define MCAUSE_FAULT_FETCH              ((0 << `MCAUSE_INT) | 1)
`define MCAUSE_ILLEGAL_INSTRUCTION      ((0 << `MCAUSE_INT) | 2)
`define MCAUSE_BREAKPOINT               ((0 << `MCAUSE_INT) | 3)
`define MCAUSE_MISALIGNED_LOAD          ((0 << `MCAUSE_INT) | 4)
`define MCAUSE_FAULT_LOAD               ((0 << `MCAUSE_INT) | 5)
`define MCAUSE_MISALIGNED_STORE         ((0 << `MCAUSE_INT) | 6)
`define MCAUSE_FAULT_STORE              ((0 << `MCAUSE_INT) | 7)
`define MCAUSE_ECALL_U                  ((0 << `MCAUSE_INT) | 8)
`define MCAUSE_ECALL_S                  ((0 << `MCAUSE_INT) | 9)
`define MCAUSE_ECALL_H                  ((0 << `MCAUSE_INT) | 10)
`define MCAUSE_ECALL_M                  ((0 << `MCAUSE_INT) | 11)
`define MCAUSE_PAGE_FAULT_INST          ((0 << `MCAUSE_INT) | 12)
`define MCAUSE_PAGE_FAULT_LOAD          ((0 << `MCAUSE_INT) | 13)
`define MCAUSE_PAGE_FAULT_STORE         ((0 << `MCAUSE_INT) | 15)
`define MCAUSE_INTERRUPT                (1 << `MCAUSE_INT)

//--------------------------------------------------------------------
// Debug
//--------------------------------------------------------------------
`define RISCV_REGNO_FIRST   13'd0
`define RISCV_REGNO_GPR0    13'd0
`define RISCV_REGNO_GPR31   13'd31
`define RISCV_REGNO_PC      13'd32
`define RISCV_REGNO_CSR0    13'd65
`define RISCV_REGNO_CSR4095 (`RISCV_REGNO_CSR0 +  13'd4095)
`define RISCV_REGNO_PRIV    13'd4161
