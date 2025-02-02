// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module InstructionCache (
  IntfCSB.notag cs,

  input  wire [31:0] i_address[2],
  input  wire        i_read   [2],
  output reg  [31:0] o_instr  [2],
  output reg         o_hit    [2],

  IntfMemory.InstrCache memory
);
  // ------------------------------- Parameters -------------------------------
  // FOR DEBUG PURPOSES TO TEST BEST SIZE
  localparam int SETS = 8;
  localparam int SET_BITS = $clog2(SETS);

  localparam int TAG_LOW_RANGE = (SET_BITS + 5);
  localparam int TAG_SIZE = 32 - TAG_LOW_RANGE;
  // ------------------------------- Structures -------------------------------
  typedef enum logic [1:0] {
    VALID,
    INVALID,
    MODIFIED
  } data_state_e;

  typedef struct packed {
    logic [TAG_SIZE-1:0] tag;
    logic [7:0][31:0]    words;
    data_state_e         state;
  } cache_set_t;

  // ------------------------------- Wires -------------------------------
  logic       [SET_BITS - 1:0] set_select [   2];
  logic       [           2:0] word_select[   2];
  bit                          miss       [   2];
  cache_set_t                  data       [SETS];
  // ------------------------------- Behaviour -------------------------------
  generate
    for (genvar i = 0; i < 2; i++) begin : gen_selects
      /*assign word_select[i] = i_address[i][4:2];
      assign set_select[i]  = i_address[i][SET_BITS+4:5];*/

      always_comb begin : cache_read
        if (cs.reset) begin
          o_instr[i] = '0;
          o_hit[i]   = '0;
          miss[i]    = '0;
        end else begin
          word_select[i] = i_address[i][4:2];
          set_select[i]  = i_address[i][SET_BITS+4:5];
          if (i_read[i]) begin
            if ((i_address[i][31:TAG_LOW_RANGE] == data[set_select[i]].tag) &&
              (data[set_select[i]].state == VALID)) begin
              o_instr[i] = data[set_select[i]].words[word_select[i]];
              o_hit[i]   = '1;
              miss[i]    = '0;
            end else begin
              o_instr[i] = '0;
              o_hit[i]   = '0;
              miss[i]    = '1;
            end
          end else begin
            o_instr[i] = '0;
            o_hit[i]   = '0;
            miss[i]    = '0;
          end
        end  //cache_read
      end
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
          data[set_select[0]].tag   <= i_address[0][31:TAG_LOW_RANGE];
          data[set_select[0]].words <= memory.data;
          data[set_select[0]].state <= VALID;
        end else begin
          memory.address <= i_address[0];
          memory.read    <= '1;
        end
      end else if (miss[1]) begin
        if (memory.ready) begin
          data[set_select[1]].tag   <= i_address[1][31:TAG_LOW_RANGE];
          data[set_select[1]].words <= memory.data;
          data[set_select[1]].state <= VALID;
        end else begin
          memory.address <= i_address[1];
          memory.read    <= '1;
        end
      end else begin
        memory.address <= '0;
        memory.read    <= '0;
      end
    end
  end  //miss_mem_fetch
endmodule
