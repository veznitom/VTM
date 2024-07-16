// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CPU #(
  parameter int BUS_WIDTH_BYTES   = 256,
  parameter int INSTR_CACHE_WORDS = 4,
  parameter int INSTR_CACHE_SETS  = 8,
  parameter int DATA_CACHE_WORDS  = 4,
  parameter int DATA_CACHE_SETS   = 10
) (
  input logic i_clock,
  input logic i_reset,

  ifc_memory f_memory
);

  ifc_memory #(.BUS_WIDTH_BYTES(INSTR_CACHE_WORDS * 4)) f_instr_mem ();
  ifc_memory #(.BUS_WIDTH_BYTES(DATA_CACHE_WORDS * 4)) f_data_mem ();
  ifc_instr_cache f_instr_cache[2] ();
  ifc_data_cache f_data_cahce ();
  ifc_common_data_bus f_data_bus[2] ();

  MemoryManagementUnit u_mmu (i_clock);

  InstructionCache #(
    .SETS (INSTR_CACHE_SETS),
    .WORDS(INSTR_CACHE_WORDS)
  ) u_instr_cache (
    .i_clock (i_clock),
    .i_reset (i_reset),
    .f_memory(f_instr_mem),
    .f_cache (f_instr_cache)
  );

  DataCache #(
    .SETS (DATA_CACHE_SETS),
    .WORDS(DATA_CACHE_WORDS)
  ) u_data_cahce (
    .i_clock   (i_clock),
    .i_reset   (i_reset),
    .f_memory  (f_data_mem),
    .f_cache   (f_data_cahce),
    .f_data_bus(f_data_bus)
  );

  /*
  ip_wrapper ip_wrapper ();

  register_file reg_file ();

  reorder_buffer #() reorder_buffer ();

  combo_alu #() combo_alu ();

  combo_branch #() combo_branch ();

  combo_load_store #() combo_load_store ();

  combo_mult_div #() combo_mult_div ();*/

endmodule
