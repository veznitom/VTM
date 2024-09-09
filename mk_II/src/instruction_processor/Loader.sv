// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Loader #(
  parameter bit [31:0] RESET_VECTOR = '0
) (
  IntfCSB.notag         cs,
  IntfInstrCache.Loader cache[2],

  input wire [31:0] i_jmp_address,
  input wire        i_jmp_write,

  output reg [31:0] o_address[2],
  output reg [31:0] o_instr  [2],

  input wire i_halt
);
  // ------------------------------- Regs -------------------------------
  reg [31:0] pc;

  // ------------------------------- Behaviour -------------------------------
  assign cache[0].address = pc;
  assign cache[1].address = pc + 4;
  assign cache[0].read    = (~i_halt) ? '1 : '0;
  assign cache[1].read    = (~i_halt) ? '1 : '0;

  always_ff @(posedge cs.clock) begin : instr_load
    if (cs.reset) begin
      o_address <= {'0, '0};
      o_instr   <= {'0, '0};
      pc        <= RESET_VECTOR;
      if (!i_halt) begin
        if (cache[0].hit && cache[1].hit) begin
          o_address[0] <= pc;
          o_address[1] <= pc + 4;
          o_instr[0]   <= cache[0].instr;
          o_instr[1]   <= cache[1].instr;
          pc           <= pc + 8;
        end else begin
          o_address[0] <= '0;
          o_address[1] <= '0;
          o_instr[0]   <= NOP_INSTR;
          o_instr[1]   <= NOP_INSTR;
        end
      end
    end
  end
endmodule
