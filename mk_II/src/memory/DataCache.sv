// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module DataCache (
  IntfCSB.notag           cs,
  IntfDataCache.DataCache cache,
  IntfCDB.Cache           data_bus[2],

  input  logic         i_mem_ready,
  input  logic         i_mem_done,
  inout  logic [255:0] io_mem_data,
  output logic [ 31:0] o_mem_address,
  output logic         o_mem_read,
  output logic         o_mem_write
);
  // ------------------------------- Parameters -------------------------------
  // FOR DEBUG PURPOSES TO TEST BEST SIZE
  localparam int SETS = 8;
  localparam int SET_BITS = $clog2(SETS);

  localparam int TAG_LOW_RANGE = (SET_BITS + 5);
  localparam int TAG_SIZE = 32 - TAG_LOW_RANGE;

  // ------------------------------- Wires -------------------------------
  logic [SET_BITS-1:0] set_select;
  logic [         2:0] word_select;
  logic [         1:0] byte_select;

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [TAG_SIZE-1:0] tag;
    logic [7:0][31:0]    words;
    cache_state_e        state;
  } cache_set_t;

  typedef struct packed {
    logic [31:0]      address;
    logic [7:0][31:0] words;
  } wb_record_t;

  // ------------------------------- Wires -------------------------------
  cache_set_t data        [SETS];
  wb_record_t write_buffer[SETS];
  logic [3:0] read_index, write_index;
  logic read, empty, miss, write_back;

  // ------------------------------- Behaviour -------------------------------
  /*
  assign byte_select = cache.address[1:0];
  assign word_select = cache.address[3+1:2];
  assign set_select  = cache.address[SET_BITS+3+1:3+2];

  always_ff @(posedge cs.clock) begin : cache_read
    if (cs.reset) begin
      miss        <= '0;
      cache.data  <= '0;
      cache.hit   <= '0;
      cache.ready <= '0;
    end else if (cache.read && !write_back) begin
      if ((cache.address[31:(SET_BITS+3+2)] == data[set_select].tag) &&
          (data[set_select].state == VALID)) begin
        miss       <= 1'h0;
        cache.hit  <= 1'h1;
        cache.data <= data[set_select].words[word_select];
      end else begin
        miss      <= 1'h1;
        cache.hit <= 1'h0;
      end
    end else cache.hit <= 1'h0;
  end  //cache_read

  always_ff @(posedge cs.clock) begin : write_buffer_write
    if (cs.reset) begin
      read_index  <= '0;
      write_index <= '0;
      foreach (write_buffer[i]) begin
        write_buffer[i] <= '{{32{1'h0}}, {32 * 8{1'h0}}};
      end
    end else begin
      if (read && !empty) begin
        read_index <= read_index + 1;
      end

      if (miss && !write_back) begin
        if (memory.ready) begin
          memory.read            <= 1'h0;
          memory.address         <= {32{1'h0}};

          data[set_select].tag   <= cache.address[31:(SET_BITS+3+2)];
          data[set_select].words <= memory.data;
          data[set_select].state <= VALID;
        end else begin
          memory.read    <= 1'h1;
          memory.address <= cache.address;
        end
      end

      if (cache.write && !write_back) begin
        if (cache.address[31:(SET_BITS+3+2)] == data[set_select].tag &&
          data[set_select].state == MODIFIED) begin
          write_buffer[write_index] <= '{
              {data[set_select].tag, set_select, {3 + 2{1'h0}}},
              data[set_select].words
          };
          write_index <= write_index + 1;
        end
        data[set_select].tag <= cache.address[31:(SET_BITS+3+2)];
        data[set_select].words[word_select] <= cache.data;
        data[set_select].state <= MODIFIED;
      end
    end
  end  //write_buffer_write

  always_ff @(posedge cs.clock) begin : memory_write_back
    if (cs.reset) begin
      cache.hit      <= '0;
      memory.address <= '0;
      memory.data    <= '0;
      memory.read    <= '0;
      memory.write   <= '0;
    end else if (write_back) begin
      if (memory.done) begin
        memory.write   <= '0;
        memory.address <= '0;
        memory.data    <= '0;

        write_back     <= '0;
        read           <= '1;
      end else begin
        memory.write   <= '1;
        memory.address <= write_buffer[0].address;
        memory.data    <= write_buffer[0].words;

        read           <= 1'h0;
      end
    end else if (empty) begin
      write_back <= 1'h0;
      read       <= 1'h0;
    end else if (!empty && !memory.read && memory.write) begin
      write_back <= 1'h1;
      read       <= 1'h0;
    end else read <= 1'h0;
  end  //memory_write_back

  // Queue control ------------------------------------------------------------

  always_comb begin
    if (cs.reset) begin

    end
  end

  always_ff @(posedge cs.clock) begin

  end

  always_comb begin
    if (read_index == write_index) empty = 1'h1;
    else empty = 1'h0;
  end
  */
endmodule
