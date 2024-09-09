// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module InstructionCache (
  IntfCSB.notag             cs,
  IntfMemory.Cache          memory,
  IntfInstrCache.InstrCache cache [2]
);
  // ------------------------------- Parameters -------------------------------
  // DO NOT CHANGE
  localparam int WORDS = 8;
  localparam int WordBits = 3;

  localparam int SETS = 8;
  localparam int SetBits = $clog2(SETS);
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
      assign byte_select[i] = cache[i].address[1:0];
      assign word_select[i] = cache[i].address[WordBits+1:2];
      assign set_select[i]  = cache[i].address[SetBits+WordBits+1:WordBits+2];

      always_comb begin : cache_read
        if (cs.reset) begin
          cache[i].instr = '0;
          cache[i].hit   = '0;
          miss[i]        = 1'b0;
        end else if (cache[i].read) begin
          if (
          (cache[i].address[31:(SetBits+WordBits+2)] == data[set_select[i]].tag)
            && (data[set_select[i]].state == VALID)) begin
            miss[i]        = 1'h0;
            cache[i].hit   = 1'h1;
            cache[i].instr = data[set_select[i]].words[word_select[i]];
          end else begin
            miss[i]        = 1'h1;
            cache[i].instr = '0;
            cache[i].hit   = '0;
          end
        end else begin
          miss[i]        = 1'h0;
          cache[i].instr = {32{1'h0}};
          cache[i].hit   = 1'h0;
        end
      end  //cache_read
    end
  endgenerate

  always_ff @(posedge cs.clock) begin : miss_mem_fetch
    if (cs.reset) begin
      memory.address <= '0;
      memory.read    <= '0;
      foreach (data[i]) begin
        data[i].tag   <= '0;
        data[i].words <= '0;
        data[i].state <= INVALID;
      end
    end else begin
      if (miss[0]) begin
        if (memory.ready) begin
          if (memory.ready) begin
            data[set_select[0]].tag <= memory.address[31:(SetBits+WordBits+2)];
            data[set_select[0]].words <= memory.data;
            data[set_select[0]].state <= VALID;
          end else begin
            memory.address <= cache[0].address;
            memory.read    <= '1;
          end
        end else if (miss[1]) begin
          if (memory.ready) begin
            data[set_select[1]].tag <= memory.address[31:(SetBits+WordBits+2)];
            data[set_select[1]].words <= memory.data;
            data[set_select[1]].state <= VALID;
          end else begin
            memory.address <= cache[1].address;
            memory.read    <= '1;
          end
        end
      end else begin
        memory.address <= '0;
        memory.read    <= '0;
      end
    end
  end  //miss_mem_fetch
endmodule
