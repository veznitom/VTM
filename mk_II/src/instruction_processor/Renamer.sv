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
  reg [1:0] ren_cap;

  always_comb begin
    if (i_reset) begin
      ren_cap     = '0;
      o_ren_empty = '0;
      o_branch    = '0;
    end else begin
      ren_cap =
      (i_instr_info[0].flags.writes && i_instr_info[0].regs.rd != 0) +
      (i_instr_info[1].flags.writes && i_instr_info[1].regs.rd != 0);
      o_ren_empty = ren_cap > i_query_ren_capacity;
      o_branch = i_instr_info[0].flags.jumps || i_instr_info[1].flags.jumps;
    end
  end

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      o_query_input_regs[0] <= '{0, 0, 0, 0};
      o_query_rename[0]     <= '0;
      o_query_tag[0]        <= '0;

      o_query_input_regs[1] <= '{0, 0, 0, 0};
      o_query_rename[1]     <= '0;
      o_query_tag[1]        <= '0;

      o_instr_info[0].clear();
      o_instr_info[1].clear();
    end else if (!i_halt) begin
      if (ren_cap <= i_query_ren_capacity) begin
        o_query_input_regs[0] <= i_instr_info[0].regs;
        if (i_instr_info[0].flags.writes && i_instr_info[0].regs.rd != 0) begin
          o_query_rename[0] <= '1;
        end else o_query_rename[0] <= '0;
        o_query_tag[0]        <= i_tag;

        o_query_input_regs[1] <= i_instr_info[1].regs;
        if (i_instr_info[1].flags.writes && i_instr_info[1].regs.rd != 0) begin
          o_query_rename[1] <= '1;
        end else o_query_rename[1] <= '0;
        o_query_tag[1]             <= i_tag;

        o_instr_info[0].address    <= i_instr_info[0].address;
        o_instr_info[0].immediate  <= i_instr_info[0].immediate;
        o_instr_info[0].instr_name <= i_instr_info[0].instr_name;
        o_instr_info[0].instr_type <= i_instr_info[0].instr_type;
        o_instr_info[0].regs       <= i_instr_info[0].regs;
        o_instr_info[0].flags      <= i_instr_info[0].flags;

        o_instr_info[1].address    <= i_instr_info[1].address;
        o_instr_info[1].immediate  <= i_instr_info[1].immediate;
        o_instr_info[1].instr_name <= i_instr_info[1].instr_name;
        o_instr_info[1].instr_type <= i_instr_info[1].instr_type;
        o_instr_info[1].regs       <= i_instr_info[1].regs;
        o_instr_info[1].flags      <= i_instr_info[1].flags;
      end else begin
        o_query_input_regs[0] <= '{0, 0, 0, 0};
        o_query_rename[0]     <= '0;
        o_query_tag[0]        <= '0;

        o_query_input_regs[1] <= '{0, 0, 0, 0};
        o_query_rename[1]     <= '0;
        o_query_tag[1]        <= '0;

        o_instr_info[0].clear();
        o_instr_info[1].clear();
      end
    end
  end
endmodule
