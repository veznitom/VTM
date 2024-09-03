// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Resolver (
  IntfCSB.tag           cs,
  IntfRegQuery.Resolver query       [2],
  IntfInstrInfo.In      i_instr_info[2],
  IntfInstrInfo.Out     o_instr_info[2],

  input  wire i_halt,
  output wire o_panic
);
  function automatic bit match_regs(input logic [5:0] rd, input logic [5:0] rs);
    return (rd != 6'h00 && rd == rs);
  endfunction

  logic tag_active;

  always_comb begin : reset
    if (cs.reset) begin
      tag_active = 1'h0;
    end
  end

  /*always_comb begin : stops
    if (
      i_instr_info[0].instr_name != UNKNOWN &&
      i_instr_info[1].instr_name != UNKNOWN) begin
      if ((i_instr_info[0].flags.writes && query[0].outputs.rn == 6'h00)
      || (i_instr_info[1].flags.writes && query[1].outputs.rn == 6'h00))
      begin
        instr_proc.resolver_stop = 1'h1;
      end else instr_proc.resolver_stop = 1'h0;
    end else instr_proc.resolver_stop = 1'h0;
  end*/

  always_ff @(posedge cs.clock) begin : fetch
    if (
        //!instr_proc.issuer_stop &&
        i_instr_info[0].instr_name != UNKNOWN &&
      i_instr_info[1].instr_name != UNKNOWN)
    begin
      o_instr_info[0].address    <= i_instr_info[0].address;
      o_instr_info[0].immediate  <= i_instr_info[0].immediate;
      o_instr_info[0].instr_name <= i_instr_info[0].instr_name;
      o_instr_info[0].regs.rs_1  <= query[0].outputs.rs_1;
      o_instr_info[0].regs.rs_2  <= query[0].outputs.rs_2;
      o_instr_info[0].regs.rd    <= i_instr_info[0].regs.rd;
      if (i_instr_info[0].flags.writes && i_instr_info[0].regs.rd != 5'h0) begin
        o_instr_info[0].regs.rn <= query[0].outputs.rn;
      end else o_instr_info[0].regs.rn <= 6'h00;
      o_instr_info[0].instr_type <= i_instr_info[0].instr_type;
      o_instr_info[0].flags <= i_instr_info[0].flags;
      o_instr_info[0].flags.tag <=
        i_instr_info[0].flags.jumps ? 1'b0 : tag_active;

      o_instr_info[1].address <= i_instr_info[1].address;
      o_instr_info[1].immediate <= i_instr_info[1].immediate;
      o_instr_info[1].instr_name <= i_instr_info[1].instr_name;
      if (match_regs(i_instr_info[0].regs.rd, i_instr_info[1].regs.rs_1)) begin
        o_instr_info[1].regs.rs_1 <= query[0].outputs.rn;
      end else o_instr_info[1].regs.rs_1 <= query[1].outputs.rs_1;
      if (match_regs(i_instr_info[0].regs.rd, i_instr_info[1].regs.rs_2)) begin
        o_instr_info[1].regs.rs_2 <= query[0].outputs.rn;
      end else o_instr_info[1].regs.rs_2 <= query[1].outputs.rs_2;
      o_instr_info[1].regs.rd <= i_instr_info[1].regs.rd;
      if (i_instr_info[1].flags.writes && i_instr_info[1].regs.rd != 6'h00)
      begin
        o_instr_info[1].regs.rn <= query[1].outputs.rn;
      end else o_instr_info[1].regs.rn <= 6'h00;
      o_instr_info[1].instr_type <= i_instr_info[1].instr_type;
      o_instr_info[1].flags      <= i_instr_info[1].flags;
      if (i_instr_info[1].flags.jumps) o_instr_info[1].flags.tag <= 1'b0;
      else if (i_instr_info[0].flags.jumps) begin
        o_instr_info[1].flags.tag <= 1'b1;
      end else o_instr_info[1].flags.tag <= tag_active;
    end
  end
endmodule

