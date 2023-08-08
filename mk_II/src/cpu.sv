import structures::*;

module cpu #(
    parameter int XLEN = 32
) (
    memory_bus_if.cpu memory_bus,
    cpu_debug_if debug,
    input logic clock,
    input logic reset
);

  localparam int InstrCacheWords = memory_bus.BUS_WIDTH_BYTES / 4;
  localparam int InstrCacheSets = 4;

  localparam int DataCacheWords = memory_bus.BUS_WIDTH_BYTES / 4;
  localparam int DataCacheSets = 4;

  global_bus_if global_bus (
      .clock(clock),
      .reset(reset)
  );
  memory_bus_if #(.BUS_WIDTH_BYTES(memory_bus.BUS_WIDTH_BYTES)) data_memory_bus ();
  memory_bus_if #(.BUS_WIDTH_BYTES(memory_bus.BUS_WIDTH_BYTES)) instr_memory_bus ();
  memory_bus_if #(.BUS_WIDTH_BYTES(XLEN / 8)) instr_cache_bus[2] ();
  memory_bus_if #(.BUS_WIDTH_BYTES(XLEN / 8)) data_cache_bus[1] ();

  common_data_bus_if data_bus[2] ();
  common_data_bus_if dummy[2] ();

  pc_bus_if pc_bus ();
  issue_bus_if issue[2] ();
  reg_query_bus_if query[2] ();
  reg_val_bus_if reg_val[2] ();
  fullness_bus_if fullness ();

  memory_management_unit mmu (
      .global_bus(global_bus),
      .data_bus  (data_memory_bus),
      .instr_bus (instr_memory_bus),
      .memory_bus(memory_bus)
  );

  cache #(
      .XLEN (XLEN),
      .SETS (InstrCacheSets),
      .WORDS(InstrCacheWords),
      .PORTS(2)
  ) instr_cache (
      .global_bus(global_bus),
      .cpu_bus(instr_cache_bus),
      .memory_bus(instr_memory_bus),
      .data_bus(dummy)
  );

  cache #(
      .XLEN (XLEN),
      .SETS (DataCacheSets),
      .WORDS(DataCacheWords),
      .PORTS(1)
  ) data_cache (
      .global_bus(global_bus),
      .cpu_bus(data_cache_bus),
      .memory_bus(data_memory_bus),
      .data_bus(data_bus)
  );

  program_counter #(
      .XLEN(XLEN)
  ) pc (
      .global_bus(global_bus),
      .pc_bus(pc_bus)
  );

  instr_processer #(
      .XLEN(XLEN)
  ) instr_processer (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .cache_bus(instr_cache_bus),
      .query(query),
      .fullness(fullness),
      .issue(issue),
      .reg_val(reg_val),
      .data_bus(data_bus)
  );

  register_file #(
      .XLEN(XLEN)
  ) register_file (
      .global_bus(global_bus),
      .query(query),
      .reg_val(reg_val),
      .debug(debug)
  );

  reorder_buffer #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h01)
  ) reorder_buffer (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .data_bus(data_bus),
      .issue(issue),
      .full(fullness.rob)
  );

  alu_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h02)
  ) alu_combo (
      .global_bus(global_bus),
      .issue(issue),
      .data_bus(data_bus),
      .full(fullness.alu)
  );
  branch_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h05)
  ) branch_combo (
      .global_bus(global_bus),
      .issue(issue),
      .data_bus(data_bus),
      .full(fullness.branch)
  );
  load_store_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h04)
  ) load_store_combo (
      .global_bus(global_bus),
      .issue(issue),
      .data_bus(data_bus),
      .cache_bus(data_cache_bus),
      .full(fullness.load_store)
  );
  mult_div_combo #(
      .XLEN(XLEN),
      .ARBITER_ADDRESS(8'h03)
  ) mult_div_combo (
      .global_bus(global_bus),
      .issue(issue),
      .data_bus(data_bus),
      .full(fullness.mult_div)
  );

  assign instr_cache_bus[0].address = pc_bus.address;
  assign instr_cache_bus[1].address = pc_bus.address + 4;

  /*genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_zero
      assign instr_cache_bus[i].write = 1'h0;
      assign instr_cache_bus[i].tag   = 1'h0;
    end

    always_comb begin : clear_isssue
      if (reset) issue[i].clear();
    end
  endgenerate

  */ always_comb begin : clear_wires
    if (reset) begin
      data_bus[0].clear();
      data_bus[1].clear();
    end
  end
endmodule
