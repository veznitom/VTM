import global_variables::XLEN;
import structures::*;

module cpu #(
    parameter int INSTR_CACHE_WORDS = 4,
    parameter int INSTR_CACHE_SETS = 8,
    parameter int DATA_CACHE_WORDS = 4,
    parameter int DATA_CACHE_SETS = 10
) (
    memory_bus_if.cpu memory_bus,
    cpu_debug_if debug,
    input logic clock,
    input logic reset
);
  global_bus_if global_bus (
      .clock(clock),
      .reset(reset)
  );
  memory_bus_if #(.BUS_WIDTH_BYTES(DATA_CACHE_WORDS * (XLEN / 8))) data_memory_bus ();
  memory_bus_if #(.BUS_WIDTH_BYTES(INSTR_CACHE_WORDS * (XLEN / 8))) instr_memory_bus ();
  instr_cache_bus_if instr_cache_bus[2] ();
  data_cache_bus_if data_cache_bus ();

  common_data_bus_if data_bus[2] ();
  common_data_bus_if dummy[2] ();

  pc_bus_if pc_bus ();
  issue_bus_if issue_bus[2] ();
  reg_query_bus_if query_bus[2] ();
  reg_val_bus_if reg_val_bus[2] ();
  fullness_bus_if fullness ();

  memory_management_unit mmu (
      .global_bus(global_bus),
      .data_bus  (data_memory_bus),
      .instr_bus (instr_memory_bus),
      .memory_bus(memory_bus)
  );

  instr_cache #(
      .SETS (INSTR_CACHE_SETS),
      .WORDS(INSTR_CACHE_WORDS)
  ) instr_cache (
      .global_bus(global_bus),
      .memory_bus(instr_memory_bus),
      .cache_bus (instr_cache_bus)
  );

  data_cache #(
      .SETS (DATA_CACHE_SETS),
      .WORDS(DATA_CACHE_WORDS)
  ) data_cache (
      .global_bus(global_bus),
      .memory_bus(data_memory_bus),
      .cache_bus (data_cache_bus),
      .data_bus  (data_bus)
  );

  /*program_counter pc (
      .global_bus(global_bus),
      .pc_bus(pc_bus)
  );*/

  instr_processer instr_processer (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .cache_bus(instr_cache_bus),
      .query_bus(query_bus),
      .fullness(fullness),
      .issue_bus(issue_bus),
      .reg_val_bus(reg_val_bus),
      .data_bus(data_bus)
  );

  register_file reg_file (
      .global_bus(global_bus),
      .query_bus(query_bus),
      .reg_val_bus(reg_val_bus),
      .data_bus(data_bus),
      .debug(debug)
  );

  reorder_buffer #(
      .ARBITER_ADDRESS(8'h01)
  ) reorder_buffer (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .data_bus(data_bus),
      .issue_bus(issue_bus),
      .full(fullness.rob)
  );

  alu_combo #(
      .ARBITER_ADDRESS(8'h02)
  ) alu_combo (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .full(fullness.alu)
  );
  branch_combo #(
      .ARBITER_ADDRESS(8'h05)
  ) branch_combo (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .full(fullness.branch)
  );
  load_store_combo #(
      .ARBITER_ADDRESS(8'h04)
  ) load_store_combo (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .cache_bus(data_cache_bus),
      .data_bus(data_bus),
      .full(fullness.load_store)
  );
  mult_div_combo #(
      .ARBITER_ADDRESS(8'h03)
  ) mult_div_combo (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .full(fullness.mult_div)
  );

  /*assign instr_cache_bus[0].address_in = pc_bus.address;
  assign instr_cache_bus[1].address_in = pc_bus.address + 4;*/

  always_comb begin : clear_wires
    if (reset) begin
      data_bus[0].clear();
      data_bus[1].clear();
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_zero
      always_comb begin : gen_cdb_clear
        if (reset) data_bus[i].clear();
      end
    end
  endgenerate
endmodule
