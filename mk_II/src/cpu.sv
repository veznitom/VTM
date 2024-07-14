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
    input logic i_reset
);
  MemoryManagementUnit u_mmu ();
/*
  cache_instr #() instr_cache ();

  cache_data #() data_cache ();

  ip_wrapper ip_wrapper ();

  register_file reg_file ();

  reorder_buffer #() reorder_buffer ();

  combo_alu #() combo_alu ();

  combo_branch #() combo_branch ();

  combo_load_store #() combo_load_store ();

  combo_mult_div #() combo_mult_div ();*/

endmodule
