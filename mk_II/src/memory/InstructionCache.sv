// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module InstructionCache (
  IntfCSB.notag cs,

  input  logic [31:0] i_address[2],
  input  logic        i_read   [2],
  output logic [31:0] o_instr  [2],
  output logic        o_hit    [2],


  input  logic [255:0] i_mem_data,
  input  logic         i_mem_ready,
  output logic [ 31:0] o_mem_address,
  output logic         o_mem_read
);
  // ------------------------------- Parameters -------------------------------
  // FOR DEBUG PURPOSES TO TEST BEST SIZE
  localparam int SETS = 8;
  localparam int SET_BITS = $clog2(SETS);

  localparam int TAG_LOW_RANGE = (SET_BITS + 5);
  localparam int TAG_SIZE = 32 - TAG_LOW_RANGE;
  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [TAG_SIZE-1:0] tag;
    logic [0:7][31:0]    words;
    cache_state_e        state;
  } cache_set_t;

  // ------------------------------- Wires -------------------------------
  logic       [SET_BITS - 1:0] set_select [   2];
  logic       [           2:0] word_select[   2];
  logic       [           1:0] byte_select[   2];
  bit                          miss       [   2];
  cache_set_t                  data       [SETS];
  // ------------------------------- Behaviour -------------------------------
  generate
    for (genvar i = 0; i < 2; i++) begin : gen_selects
      assign byte_select[i] = i_address[i][1:0];
      assign word_select[i] = i_address[i][4:2];
      assign set_select[i]  = i_address[i][SET_BITS+4:5];

      always_comb begin : cache_read
        if (cs.reset) begin
          o_instr[i] = '0;
          o_hit[i]   = '0;
          miss[i]    = 1'b0;
        end else if (i_read[i]) begin
          if (
          (i_address[i][31:TAG_LOW_RANGE] == data[set_select[i]].tag)
            && (data[set_select[i]].state == VALID)) begin
            miss[i]    = 1'h0;
            o_hit[i]   = 1'h1;
            o_instr[i] = data[set_select[i]].words[word_select[i]];
          end else begin
            miss[i]    = 1'h1;
            o_instr[i] = '0;
            o_hit[i]   = '0;
          end
        end else begin
          miss[i]    = 1'h0;
          o_instr[i] = {32{1'h0}};
          o_hit[i]   = 1'h0;
        end
      end  //cache_read
    end
  endgenerate

  always_ff @(posedge cs.clock) begin : miss_mem_fetch
    if (cs.reset) begin
      o_mem_address <= '0;
      o_mem_read    <= '0;
      foreach (data[i]) begin
        data[i].tag   <= '0;
        data[i].words <= '0;
        data[i].state <= INVALID;
      end
    end else begin
      if (miss[0]) begin
        if (i_mem_ready) begin
          data[set_select[0]].tag   <= i_address[0][31:TAG_LOW_RANGE];
          data[set_select[0]].words <= i_mem_data;
          data[set_select[0]].state <= VALID;
        end else begin
          o_mem_address <= i_address[0];
          o_mem_read    <= '1;
        end
      end else if (miss[1]) begin
        if (i_mem_ready) begin
          data[set_select[1]].tag   <= i_address[1][31:TAG_LOW_RANGE];
          data[set_select[1]].words <= i_mem_data;
          data[set_select[1]].state <= VALID;
        end else begin
          o_mem_address <= i_address[1];
          o_mem_read    <= '1;
        end
      end else begin
        o_mem_address <= '0;
        o_mem_read    <= '0;
      end
    end
  end  //miss_mem_fetch
endmodule
