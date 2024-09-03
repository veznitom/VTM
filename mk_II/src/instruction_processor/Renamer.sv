// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Renamer (
  IntfCSB.tag          cs,
  IntfInstrInfo.In     i_instr_info[2],
  IntfInstrInfo.Out    o_instr_info[2],
  IntfRegQuery.Renamer query       [2],

  input  wire i_halt,
  output wire o_no_ren
);
endmodule
