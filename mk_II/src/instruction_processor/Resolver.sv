// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Resolver (
  input wire i_clock,
  input wire i_reset,

  // Query
  input registers_t i_query_output_regs[2],

  // Info
  IntfInstrInfo.In  i_instr_info[2],
  IntfInstrInfo.Out o_instr_info[2],

  // Constrol
  input  wire i_halt,
  input  wire i_tag,
  output reg  o_panic
);
  function automatic bit match_regs(input logic [5:0] rd, input logic [5:0] rs);
    return (rd != 6'h00 && rd == rs);
  endfunction

  always_comb begin
    if (i_instr_info[0].flags.jumps && i_instr_info[1].flags.jumps) begin
      o_panic = '1;
    end else o_panic = '0;
  end

  always_ff @(posedge i_clock) begin : fetch
    if (i_reset) begin
      o_instr_info[0].clear();
      o_instr_info[1].clear();
    end else if (
      i_instr_info[0].instr_name != UNKNOWN &&
      i_instr_info[1].instr_name != UNKNOWN)
    begin
      if (i_instr_info[0].flags.jumps && i_instr_info[1].flags.jumps) begin
        // Pipeline halts from renamer if tag && branch

      end else begin
        // First instruction passthrough
        o_instr_info[0].address    <= i_instr_info[0].address;
        o_instr_info[0].immediate  <= i_instr_info[0].immediate;
        o_instr_info[0].instr_name <= i_instr_info[0].instr_name;
        o_instr_info[0].regs.rs_1  <= i_query_output_regs[0].rs_1;
        o_instr_info[0].regs.rs_2  <= i_query_output_regs[0].rs_2;
        o_instr_info[0].regs.rd    <= i_instr_info[0].regs.rd;
        //if (i_instr_info[0].flags.writes && i_instr_info[0].regs.rd !='0)begin

        // should return 0 from regfile by default
        o_instr_info[0].regs.rn    <= i_query_output_regs[0].rn;

        //end else o_instr_info[0].regs.rn <= '0;
        o_instr_info[0].instr_type <= i_instr_info[0].instr_type;
        o_instr_info[0].flags      <= i_instr_info[0].flags;
        o_instr_info[0].flags.tag  <= i_instr_info[0].flags.jumps ? '0 : i_tag;

        // Second instruction passthrough
        o_instr_info[1].address    <= i_instr_info[1].address;
        o_instr_info[1].immediate  <= i_instr_info[1].immediate;
        o_instr_info[1].instr_name <= i_instr_info[1].instr_name;
        o_instr_info[1].instr_type <= i_instr_info[1].instr_type;
        o_instr_info[1].regs.rd    <= i_instr_info[1].regs.rd;
        o_instr_info[1].flags      <= i_instr_info[1].flags;

        // Second instruction first instruction dependency checks
        // 1_rd ==? 2_rs_1
        if (match_regs(
                i_instr_info[0].regs.rd, i_instr_info[1].regs.rs_1
            )) begin
          o_instr_info[1].regs.rs_1 <= i_query_output_regs[0].rn;
        end else o_instr_info[1].regs.rs_1 <= i_query_output_regs[1].rs_1;
        // 1_rd ==? 2_rs_2
        if (match_regs(
                i_instr_info[0].regs.rd, i_instr_info[1].regs.rs_2
            )) begin
          o_instr_info[1].regs.rs_2 <= i_query_output_regs[0].rn;
        end else o_instr_info[1].regs.rs_2 <= i_query_output_regs[1].rs_2;

        //if (i_instr_info[1].flags.writes && i_instr_info[1].regs.rd !='0)begin

        // should return 0 from regfile by default
        o_instr_info[1].regs.rn <= i_query_output_regs[1].rn;

        //end else o_instr_info[1].regs.rn <= '0;
        // Tag set if first jumps
        if (i_instr_info[1].flags.jumps) o_instr_info[1].flags.tag <= '0;
        else if (i_instr_info[0].flags.jumps) begin
          o_instr_info[1].flags.tag <= '1;
        end else o_instr_info[1].flags.tag <= i_tag;
      end
    end else if (i_instr_info[0].instr_name != UNKNOWN) begin

      // First instruction passthrough
      o_instr_info[0].address    <= i_instr_info[0].address;
      o_instr_info[0].immediate  <= i_instr_info[0].immediate;
      o_instr_info[0].instr_name <= i_instr_info[0].instr_name;
      o_instr_info[0].regs.rs_1  <= i_query_output_regs[0].rs_1;
      o_instr_info[0].regs.rs_2  <= i_query_output_regs[0].rs_2;
      o_instr_info[0].regs.rd    <= i_instr_info[0].regs.rd;
      //if (i_instr_info[0].flags.writes && i_instr_info[0].regs.rd !='0)begin

      // should return 0 from regfile by default
      o_instr_info[0].regs.rn    <= i_query_output_regs[0].rn;

      //end else o_instr_info[0].regs.rn <= '0;
      o_instr_info[0].instr_type <= i_instr_info[0].instr_type;
      o_instr_info[0].flags      <= i_instr_info[0].flags;
      o_instr_info[0].flags.tag  <= i_instr_info[0].flags.jumps ? '0 : i_tag;

      o_instr_info[1].clear();
    end else begin
      o_instr_info[0].clear();
      o_instr_info[1].clear();
    end
  end
endmodule

