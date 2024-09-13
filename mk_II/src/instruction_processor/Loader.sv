// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Loader #(
  parameter bit [31:0] RESET_VECTOR = '0
) (
  IntfCSB.notag cs,
  //IntfInstrCache.Loader cache[2],

  input  logic [31:0] i_cache_instr  [2],
  input  logic        i_cache_hit    [2],
  output logic [31:0] o_cache_address[2],
  output logic        o_cache_read   [2],

  input wire [31:0] i_jmp_address,
  input wire        i_jmp_write,

  output reg [31:0] o_address[2],
  output reg [31:0] o_instr  [2],

  input wire i_halt
);
  // ------------------------------- Regs -------------------------------
  reg [31:0] pc;

  // ------------------------------- Behaviour -------------------------------
  assign o_cache_address[0] = pc;
  assign o_cache_address[1] = pc + 4;
  assign o_cache_read[0]    = (~i_halt) ? '1 : '0;
  assign o_cache_read[1]    = (~i_halt) ? '1 : '0;

  always_ff @(posedge cs.clock) begin : instr_load
    if (cs.reset) begin
      o_address <= {'0, '0};
      o_instr   <= {'0, '0};
      pc        <= RESET_VECTOR;
    end else if (!i_halt) begin
      if (i_cache_hit[0] && i_cache_hit[1]) begin
        o_address[0] <= pc;
        o_address[1] <= pc + 4;
        o_instr[0]   <= i_cache_instr[0];
        o_instr[1]   <= i_cache_instr[1];
        pc           <= pc + 8;
      end else begin
        o_address[0] <= '0;
        o_address[1] <= '0;
        o_instr[0]   <= NOP_INSTR;
        o_instr[1]   <= NOP_INSTR;
      end
    end
  end
endmodule
