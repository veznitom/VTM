// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Issuer (
  input wire i_clock,
  input wire i_reset,

  IntfInstrInfo.In  i_instr_info[2],
  IntfInstrInfo.Out o_instr_info[2],

  input wire i_halt
);
  // ------------------------------- Wires -------------------------------
  // ------------------------------- Behaviour -------------------------------
  generate
    for (genvar i = 0; i < 2; i++) begin : gen_instr_info
      always_ff @(posedge i_clock) begin : issue
        if (i_reset) begin
          o_instr_info[i].clear();
        end else if (!i_halt) begin
          o_instr_info[i].address    <= i_instr_info[i].address;
          o_instr_info[i].immediate  <= i_instr_info[i].immediate;
          o_instr_info[i].instr_name <= i_instr_info[i].instr_name;
          o_instr_info[i].instr_type <= i_instr_info[i].instr_type;
          o_instr_info[i].regs       <= i_instr_info[i].regs;
          o_instr_info[i].flags      <= i_instr_info[i].flags;
        end
      end
    end
  endgenerate
endmodule
