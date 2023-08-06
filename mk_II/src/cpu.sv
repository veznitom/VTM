import structures::*;

module cpu #(
    parameter int XLEN = 32
) (
    memory_bus_if.cpu memory_bus,
    cpu_debug_if debug,
    input clk,
    reset
);

  global_signals_if gsi ();
  cache_memory_bus_if data_memory_bus (), instr_memory_bus ();
  cache_bus_if instr_cache_bus ();
  cache_bus_if data_cache_bus ();
  common_data_bus_if cdb[2] (), tmp ();
  pc_interface_if pc_if ();
  instr_issue_if issue[2] ();
  register_query_if query[2] ();
  register_values_if reg_val[2] ();
  fullness_indication_if fullness ();

  logic [XLEN-1:0] address[2];
  logic [31:0] instr[2];
  logic [1:0] hit;

  mem_mng_unit mmu (
      .gsi(gsi),
      .data_bus(data_memory_bus),
      .instr_bus(instr_memory_bus),
      .memory_bus(memory_bus)
  );

  cache #(
      .XLEN(XLEN)
  ) instr_cache (
      .gsi(gsi),
      .cache_bus(instr_cache_bus),
      .memory_bus(instr_memory_bus),
      .cdb(tmp)
  );

  cache #(
      .XLEN(XLEN)
  ) data_cache (
      .gsi(gsi),
      .cache_bus(data_cache_bus),
      .memory_bus(data_memory_bus),
      .cdb(cdb)
  );

  program_counter #(.XLEN(XLEN)) pc (.inter(pc_if));

  instr_processer #(
      .XLEN(XLEN)
  ) instr_processer (
      .gsi(gsi),
      .address(address),
      .instr(instr),
      .hit(hit),
      .query(query),
      .fullness(fullness),
      .issue(issue),
      .reg_val(reg_val),
      .cdb(cdb)
  );

  register_file #(
      .XLEN(XLEN)
  ) register_file (
      .gsi(gsi),
      .query(query),
      .reg_val(reg_val),
      .debug(debug)
  );

  reorder_buffer #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h01)
  ) reorder_buffer (
      .gsi(gsi),
      .pc(pc_if),
      .cdb(cdb),
      .issue(issue),
      .full(fullness.rob)
  );

  alu_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h02)
  ) alu_combo (
      .gsi  (gsi),
      .issue(issue),
      .cdb  (cdb),
      .full (fullness.alu)
  );
  branch_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h05)
  ) branch_combo (
      .gsi  (gsi),
      .issue(issue),
      .cdb  (cdb),
      .full (fullness.branch)
  );
  load_store_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h04)
  ) load_store_combo (
      .gsi(gsi),
      .issue(issue),
      .cdb(cdb),
      .data_bus(data_cache_bus),
      .full(fullness.load_store)
  );
  mult_div_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h03)
  ) mult_div_combo (
      .gsi  (gsi),
      .issue(issue),
      .cdb  (cdb),
      .full (fullness.mult_div)
  );

  assign address = {pc_if.address, pc_if.address + 4};

endmodule
