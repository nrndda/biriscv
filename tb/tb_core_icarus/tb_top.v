module tb_top;

`ifndef MEM_SIZE
`define MEM_SIZE 262144
`endif
`ifndef DUMPDB
`define DUMPDB 1
`endif
`ifndef TRACE
`define TRACE 1
`endif
`ifndef PRINTER2STDO
`define PRINTER2STDO 1
`endif
`ifndef PRINTER2FILE
`define PRINTER2FILE 1
`endif
`ifndef RESET_VECTOR
`define RESET_VECTOR 32'h80000000
`endif
`ifndef PRINTER_ADDR_START
`define PRINTER_ADDR_START 32'h10000000
`endif
`ifndef PRINTER_ADDR_SIZE
`define PRINTER_ADDR_SIZE 32'h00010000
`endif

reg clk;
reg rst;

reg [7:0] mem[`MEM_SIZE-1:0];
integer i,j,k,f;

integer trap;
integer trace_file;
integer print_file;
wire [3:0] print;
wire [7:0] print_byte[3:0];

initial
begin
    trap = 0;
    $display("Starting bench");

    if (`DUMPDB)
    begin
        $dumpfile("./run/waveform.vcd");
        $dumpvars(0, tb_top);
    end

    // Reset
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;

    // Load TCM memory
    for (i=0;i<`MEM_SIZE;i=i+1)
        mem[i] = 0;

    f = $fopenr("./build/tcm.bin");
    i = $fread(mem, f);
    $fclose(f);
//     $readmemh("./build/tcm.vh", mem, 0, `MEM_SIZE-1);

    for (i=0;i<`MEM_SIZE;i=i+1)
        u_mem.write(i, mem[i]);
    repeat (100000) @(posedge clk);
    $display("Reached timeout");
    trap = 1;
    repeat (10) @(posedge clk);
    $finish;
end

initial
  if (`TRACE) begin
    trace_file = $fopen("./run/testbench.trace", "w");
    @(negedge rst);
    while (!trap) begin
      @(posedge clk);
      if (u_dut.u_issue.pipe0_valid_wb_w)
        $fwrite(trace_file, "%x\n", {4'h0,u_dut.u_issue.pipe0_pc_wb_w});
      if (u_dut.u_issue.pipe1_valid_wb_w)
        $fwrite(trace_file, "%x\n", {4'h0,u_dut.u_issue.pipe1_pc_wb_w});
      $fflush (trace_file);
    end
    $fclose(trace_file);
  end

initial
  if (`PRINTER2FILE) begin
    print_file = $fopen("./run/testbench.print", "w");
    @(negedge rst);
    while (!trap) begin
      @(posedge clk);
      for (j=0; j<4; j=j+1) if (print[j]) $fwrite(print_file, "%c", print_byte[j]);
      $fflush (print_file);
    end
    $fclose(print_file);
  end

always @(posedge clk) if (`PRINTER2STDO & !trap) for (k=0; k<4; k=k+1) if (print[k]) begin $write("%c", print_byte[k]); $fflush ( ); end

initial forever clk = #5 ~clk;

wire [ 31:0]  reset_vector = `RESET_VECTOR;
wire          mem_i_rd_w;
wire          mem_i_flush_w;
wire          mem_i_invalidate_w;
wire [ 31:0]  mem_i_pc_w;
wire [ 31:0]  mem_d_addr_w;
wire [ 31:0]  mem_d_data_wr_w;
wire          mem_d_rd_w;
wire [  3:0]  mem_d_wr_w;
wire          mem_d_cacheable_w;
wire [ 10:0]  mem_d_req_tag_w;
wire          mem_d_invalidate_w;
wire          mem_d_writeback_w;
wire          mem_d_flush_w;
wire          mem_i_accept_w;
wire          mem_i_valid_w;
wire          mem_i_error_w;
wire [ 63:0]  mem_i_inst_w;
wire [ 31:0]  mem_d_data_rd_w;
wire          mem_d_accept_w;
wire          mem_d_ack_w;
wire          mem_d_error_w;
wire [ 10:0]  mem_d_resp_tag_w;

genvar G_I;
generate
  for (G_I=0; G_I<4; G_I=G_I+1) begin:PRINTER_GENBLOCK
    assign print     [G_I] = mem_d_wr_w     [G_I          ] & mem_d_accept_w & mem_d_addr_w >= `PRINTER_ADDR_START & mem_d_addr_w < `PRINTER_ADDR_START + `PRINTER_ADDR_SIZE;
    assign print_byte[G_I] = mem_d_data_wr_w[G_I*8+7:G_I*8];
  end
endgenerate

riscv_core
u_dut
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     .clk_i(clk)
    ,.rst_i(rst)
    ,.mem_d_data_rd_i(mem_d_data_rd_w)
    ,.mem_d_accept_i(mem_d_accept_w)
    ,.mem_d_ack_i(mem_d_ack_w)
    ,.mem_d_error_i(mem_d_error_w)
    ,.mem_d_resp_tag_i(mem_d_resp_tag_w)
    ,.mem_i_accept_i(mem_i_accept_w)
    ,.mem_i_valid_i(mem_i_valid_w)
    ,.mem_i_error_i(mem_i_error_w)
    ,.mem_i_inst_i(mem_i_inst_w)
    ,.intr_i(1'b0)
    ,.reset_vector_i(reset_vector)
    ,.cpu_id_i('b0)

    // Outputs
    ,.mem_d_addr_o(mem_d_addr_w)
    ,.mem_d_data_wr_o(mem_d_data_wr_w)
    ,.mem_d_rd_o(mem_d_rd_w)
    ,.mem_d_wr_o(mem_d_wr_w)
    ,.mem_d_cacheable_o(mem_d_cacheable_w)
    ,.mem_d_req_tag_o(mem_d_req_tag_w)
    ,.mem_d_invalidate_o(mem_d_invalidate_w)
    ,.mem_d_writeback_o(mem_d_writeback_w)
    ,.mem_d_flush_o(mem_d_flush_w)
    ,.mem_i_rd_o(mem_i_rd_w)
    ,.mem_i_flush_o(mem_i_flush_w)
    ,.mem_i_invalidate_o(mem_i_invalidate_w)
    ,.mem_i_pc_o(mem_i_pc_w)
);

tcm_mem
u_mem
(
    // Inputs
     .clk_i(clk)
    ,.rst_i(rst)
    ,.mem_i_rd_i(mem_i_rd_w)
    ,.mem_i_flush_i(mem_i_flush_w)
    ,.mem_i_invalidate_i(mem_i_invalidate_w)
    ,.mem_i_pc_i(mem_i_pc_w)
    ,.mem_d_addr_i(mem_d_addr_w)
    ,.mem_d_data_wr_i(mem_d_data_wr_w)
    ,.mem_d_rd_i(mem_d_rd_w)
    ,.mem_d_wr_i(mem_d_wr_w)
    ,.mem_d_cacheable_i(mem_d_cacheable_w)
    ,.mem_d_req_tag_i(mem_d_req_tag_w)
    ,.mem_d_invalidate_i(mem_d_invalidate_w)
    ,.mem_d_writeback_i(mem_d_writeback_w)
    ,.mem_d_flush_i(mem_d_flush_w)

    // Outputs
    ,.mem_i_accept_o(mem_i_accept_w)
    ,.mem_i_valid_o(mem_i_valid_w)
    ,.mem_i_error_o(mem_i_error_w)
    ,.mem_i_inst_o(mem_i_inst_w)
    ,.mem_d_data_rd_o(mem_d_data_rd_w)
    ,.mem_d_accept_o(mem_d_accept_w)
    ,.mem_d_ack_o(mem_d_ack_w)
    ,.mem_d_error_o(mem_d_error_w)
    ,.mem_d_resp_tag_o(mem_d_resp_tag_w)
);

endmodule