import structures::*;

module cpu #(
    parameter int XLEN = 32
) (
    memory_bus_if.cpu memory_bus,
    debug_interface_if debug,
    input clk,
    reset
);

  global_signals_if gsi ();
  cache_memory_bus_if data_memory_bus (), instr_memory_bus ();
  cache_bus_if instr_cache_bus ();
  cache_bus_if data_cache_bus ();
  common_data_bus_if cdb[2] ();
  pc_interface_if pc_if ();
  instr_issue_if issue_pre[2] (), issue_post[2] ();
  register_query_if query[2] ();
  register_values_if reg_val[2] ();

  logic [XLEN-1:0] addresses[2];
  logic [31:0] instrs[2];
  logic [1:0] hit;
  logic [2:0] st_fullness;

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

  program_counter #(.XLEN(XLEN)) pc (.inter(pc_if));

  instr_processer #(
      .XLEN(XLEN)
  ) instr_processer (
      .gsi(gsi),
      .addresses(addresses),
      .instrs(instrs),
      .hit(hit),
      .query(query),
      .issue(issue),
      .st_fullness(st_fullness)
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
      .issue(issue)
  );

  comparator comparator (
      .issue_in(issue_pre),
      .issue_in(issue_post),
      .reg_val(reg_val),
      .cdb(cdb)
  );

  alu_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h02)
  ) alu_combo (
      .gsi  (gsi),
      .issue(issue_post),
      .cdb  (cdb)
  );
  branch_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h05)
  ) branch_combo (
      .gsi  (gsi),
      .issue(issue_post),
      .cdb  (cdb)
  );
  load_store_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h04)
  ) load_store_combo (
      .gsi(gsi),
      .issue(issue_post),
      .cdb(cdb),
      .data_bus(data_cache_bus)
  );
  mult_div_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h03)
  ) mult_div_combo (
      .gsi  (gsi),
      .issue(issue_post),
      .cdb  (cdb)
  );

  assign addresses = {pc_if.address, pc_if.address + 4};

endmodule
