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
  generate
    for (genvar i = 0; i < 2; i++) begin : gen_var_reset

      assign cache[i].address = pc + (i * 4);
      assign cache[i].read    = i_halt ? 1'b0 : 1'b1;
    end
  endgenerate

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
          o_address[0] <= {32{1'h0}};
          o_address[1] <= {32{1'h0}};
          o_instr[0]   <= {32{1'h0}};
          o_instr[1]   <= {32{1'h0}};
        end
      end
    end
  end
endmodule
