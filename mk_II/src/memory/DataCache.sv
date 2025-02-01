// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module DataCache (
  IntfCSB.notag           cs,
  IntfDataCache.DataCache cache,
  IntfCDB.Cache           data_bus[2],

  input  wire         i_mem_ready,
  input  wire         i_mem_done,
  inout  wire [255:0] io_mem_data,
  output reg  [ 31:0] o_mem_address,
  output reg          o_mem_read,
  output reg          o_mem_write
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
  } cache_state_e;

  typedef struct packed {
    logic [TAG_SIZE-1:0] tag;
    logic [7:0][31:0]    words;
    cache_state_e        state;
  } cache_set_t;

  typedef struct packed {
    logic [31:0] address;
    logic [31:0] data;
    logic [1:0]  size;
  } write_record_t;

  // ------------------------------- Wires -------------------------------
  cache_set_t         data     [SETS];
  logic       [255:0] mem_data;
  logic miss, write_back;

  write_record_t write_fifo[16];
  logic [3:0] wf_write_index, wf_read_index;

  logic [SET_BITS-1:0] set_select;
  logic [         2:0] word_select;
  logic [         1:0] byte_select;
  logic [TAG_SIZE-1:0] tag;

  // ------------------------------- Behaviour -------------------------------

  assign io_mem_data = o_mem_write ? mem_data : 'z;

  assign byte_select = cache.address[1:0];
  assign word_select = cache.address[3+1:2];
  assign set_select  = cache.address[SET_BITS+3+1:3+2];
  assign tag         = cache.address[31-:TAG_SIZE];

  always_ff @(posedge cs.clock) begin : cache_read
    if (cs.reset) begin
      cache.dout <= '0;
      cache.hit  <= '0;
    end else begin
      if (cache.tag) begin // select if seeking the data in the write buffer of cache
        
      end
      if (data[set_select].tag == tag && data[set_select].state == VALID) begin
        miss       <= '0;
        cache.dout <= data[set_select].words[word_select];
        cache.hit  <= '1;
      end else begin
        miss       <= '1;
        cache.dout <= '0;
        cache.hit  <= '0;
      end
    end
  end  // cache_read

  always_ff @(posedge cs.clock) begin : cache_write_and_miss_handle
    if (cs.reset) begin
      foreach (data[i]) data[i] <= '{'0, '0, INVALID};

      cache.ready   <= '0;

      o_mem_address <= '0;
      o_mem_read    <= '0;
      o_mem_write   <= '0;

      mem_data      <= '0;
    end else begin
      if (cache.write) begin

      end else
      if (miss) begin

      end else begin

      end
    end
  end  // cache_write_and_miss_handle

  always_ff @(posedge cs.clock) begin : memory_write_back
  end  // memory_write_back
endmodule
