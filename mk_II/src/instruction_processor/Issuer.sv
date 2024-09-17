// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Issuer (
  input wire i_clock,
  input wire i_reset,

  IntfInstrInfo.In  i_instr_info[2],
  IntfInstrInfo.Out o_instr_info[2],
  IntfFull.Issuer   full,

  input  wire i_halt,
  output reg  o_full
);
  // ------------------------------- Wires -------------------------------
  wire fullness_split[6];

  // ------------------------------- Behaviour -------------------------------
  /*
  assign fullness_split[AL] = full.alu;
  assign fullness_split[BR] = full.branch;
  assign fullness_split[LS] = full.load_store;
  assign fullness_split[RB] = full.rob;
  assign fullness_split[MD] = full.mul_div;
  assign fullness_split[XX] = 1'h0;

  assign o_full =
    fullness_split[i_instr_info[0].instr_type] |
    fullness_split[i_instr_info[1].instr_type] |
    fullness_split[RB];

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_instr_info
      always_ff @(posedge cs.clock) begin : issue
        if (!i_halt) begin
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
  */
endmodule
