import structures::*;

module cpu #(
    parameter int XLEN = 32
) (
    memory_bus_if memory_bus,
    debug_interface_if debug,
    input clk,
    reset
);

  global_signals_if gsi ();
  cache_memory_bus_if data_memory_bus (), instr_memory_bus ();

  cache_bus_if instr_cache_bus ();
  cache_bus_if data_cache_bus ();

  common_data_bus_if cdb[2];

  mem_mng_unit mmu (
      .gsi(gsi),
      .data_bus(data_bus),
      .instr_bus(instr_bus),
      .memory_bus(memory_bus)
  );
  cache #(
      .XLEN(XLEN)
  ) instr_cache (
      .gsi(gsi),
      .cache_bus(instr_cache_bus),
      .memory_bus(instr_memory_bus),
      .cdb(_)
  );
  cache #(
      .XLEN(XLEN)
  ) data_cache (
      .gsi(gsi),
      .cache_bus(data_cache_bus),
      .memory_bus(data_memory_bus),
      .cdb(cdb)
  );

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
