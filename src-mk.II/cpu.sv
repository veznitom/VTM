`include "structures.sv"

module cpu #(
    parameter int XLEN = 32
) (
    memory_bus_if memory_bus,
    debug_interface_if debug,
    input clk,
    reset
);

  mem_mng_unit mmu ();
  cache #(.XLEN(XLEN)) instr_cache ();
  cache #(.XLEN(XLEN)) data_cache ();

  program_counter #(.XLEN(XLEN)) pc ();
  instr_processer #(.XLEN(XLEN)) instr_processer ();
  register_file #(.XLEN(XLEN)) register_file ();
  reorder_buffer #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h01)
  ) reorder_buffer ();

  comparator comparator ();

  alu_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h02)
  ) alu_combo ();
  branch_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h05)
  ) branch_combo ();
  load_store_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h04)
  ) load_store_combo ();
  mult_div_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h03)
  ) mult_div_combo ();

endmodule
