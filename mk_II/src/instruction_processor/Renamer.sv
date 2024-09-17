// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Renamer (
  input wire i_clock,
  input wire i_reset,

  // Query
  input  wire        [1:0] i_query_ren_capacity,
  output registers_t       o_query_input_regs  [2],
  output reg               o_query_rename      [2],
  output reg               o_query_tag         [2],

  // Info
  IntfInstrInfo.In  i_instr_info[2],
  IntfInstrInfo.Out o_instr_info[2],

  input  wire i_halt,
  input  wire i_tag,
  output reg  o_branch,
  output reg  o_ren_empty
);
endmodule
