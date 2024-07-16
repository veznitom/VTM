// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module InstructionCache #(
  parameter int SETS  = 8,
  parameter int WORDS = 4   // Must be > than 1
) (
  input wire i_clock,
  input wire i_reset,

  ifc_memory.cache      f_memory,
  ifc_instr_cache.cache f_cache [2]
);
  // ------------------------------- Parameters -------------------------------
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [32 - (SetBits + WordBits + 2) - 1:0] tag;
    logic [WORDS - 1:0][31:0]                   words;
    cache_state_e                               state;
  } cache_set_t;

  // ------------------------------- Wires -------------------------------
  logic       [ SetBits - 1:0] set_select [   2];
  logic       [WordBits - 1:0] word_select[   2];
  logic       [           1:0] byte_select[   2];
  bit                          miss       [   2];
  cache_set_t                  data       [SETS];
  // ------------------------------- Behaviour -------------------------------
  generate
    for (genvar i = 0; i < 2; i++) begin : gen_selects
      assign byte_select[i] = f_cache[i].address[1:0];
      assign word_select[i] = f_cache[i].address[WordBits+1:2];
      assign set_select[i]  = f_cache[i].address[SetBits+WordBits+1:WordBits+2];

      always_comb begin : cache_read
        if (i_reset) begin
          f_cache[i].instruction = '0;
          f_cache[i].hit         = '0;
          miss[i]                = 1'b0;
        end else if (f_cache[i].read) begin
          if (
            (f_cache[i].address[31:(SetBits+WordBits+2)] == data[set_select[i]].tag) 
            && (data[set_select[i]].state == VALID)) begin
            miss[i]                = 1'h0;
            f_cache[i].hit         = 1'h1;
            f_cache[i].instruction = data[set_select[i]].words[word_select[i]];
          end else begin
            miss[i]                = 1'h1;
            f_cache[i].instruction = '0;
            f_cache[i].hit         = '0;
          end
        end else begin
          miss[i]                = 1'h0;
          f_cache[i].instruction = {32{1'h0}};
          f_cache[i].hit         = 1'h0;
        end
      end  //cache_read
    end
  endgenerate

  always_ff @(posedge i_clock) begin : miss_mem_fetch
    if (i_reset) begin
      f_memory.address <= '0;
      f_memory.read    <= '0;
    end else begin
      /* TODO create miss fetch for each interface separately cos data cannot
    be written from two processes simultaneously
    */
    end
  end  //miss_mem_fetch
endmodule
