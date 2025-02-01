// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module DataCache #(
  parameter int SET_SIZE_BITS = 3
) (
  IntfCSB.notag           cs,
  IntfDataCache.DataCache cache,

  input  wire         i_mem_ready,
  input  wire         i_mem_done,
  inout  wire [255:0] io_mem_data,
  output reg  [ 31:0] o_mem_address,
  output reg          o_mem_read,
  output reg          o_mem_write
);
  // ------------------------------- Parameters -------------------------------
  localparam int TAG_SIZE = 32 - (SET_SIZE_BITS + 5);
  // ------------------------------- Structures -------------------------------
  typedef enum logic [1:0] {
    IDLE,
    LOAD,
    MODIFY,
    WRITE
  } cache_state_e;

  typedef enum logic [1:0] {
    VALID,
    INVALID,
    MODIFIED
  } data_state_e;

  typedef struct packed {
    logic [TAG_SIZE-1:0] tag;
    logic [0:7][31:0]    words;
    data_state_e         state;
  } cache_set_t;

  // ------------------------------- Wires -------------------------------
  cache_state_e         cache_state;
  cache_set_t           data        [2**SET_SIZE_BITS];
  logic         [255:0] mem_data;
  logic miss, load, write, done;

  logic [SET_SIZE_BITS-1:0] set_select;
  logic [              2:0] word_select;
  logic [              1:0] byte_select;
  logic [     TAG_SIZE-1:0] tag;

  // ------------------------------- Behaviour -------------------------------

  assign io_mem_data = o_mem_write ? mem_data : 'z;

  assign byte_select = cache.address[1:0];
  assign word_select = cache.address[3+1:2];
  assign set_select  = cache.address[SET_SIZE_BITS+3+1:3+2];
  assign tag         = cache.address[31-:TAG_SIZE];

  always_ff @(posedge cs.clock) begin : cache_read
    if (cs.reset) begin
      cache.dout <= '0;
      cache.hit  <= '0;
      miss       <= '0;
      cache.hit  <= '0;
    end else if (cache.read) begin
      if (data[set_select].tag == tag && data[set_select].state == VALID) begin
        miss       <= '0;
        cache.dout <= data[set_select].words[word_select];
        cache.hit  <= '1;
      end else begin
        miss       <= '1;
        cache.dout <= '0;
        cache.hit  <= '0;
      end
    end else begin
      cache.dout <= '0;
      cache.hit  <= '0;
      miss       <= '0;
      cache.hit  <= '0;
    end
  end  // cache_read

  always_ff @(posedge cs.clock) begin : cache_write
    if (cs.reset) begin
      load <= '0;
    end else if (cache.write) begin
      if (data[set_select].tag == tag && data[set_select].state == VALID) begin
        load <= '1;
      end else begin
        load <= '1;
      end
    end else begin
      load <= '0;
    end
  end  // cache_write

  always_ff @(posedge cs.clock) begin : data_load_and_modify
    if (cs.reset) begin
      foreach (data[i]) data[i] <= '{'0, '0, INVALID};
      o_mem_address <= '0;
      o_mem_read    <= '0;
      o_mem_write   <= '0;
      mem_data      <= '0;
      cache_state   <= IDLE;
    end else begin
      if (cache.read || cache.write) begin
        case (cache_state)
          IDLE: begin
            if (miss || load) cache_state <= LOAD;
            cache.ready <= '0;
          end
          LOAD: begin
            if (i_mem_ready) begin
              data[set_select].tag   <= cache.address[31-:TAG_SIZE];
              data[set_select].state <= VALID;
              data[set_select].words <= io_mem_data;
              o_mem_address          <= '0;
              o_mem_read             <= '0;
              if (cache.write) cache_state <= MODIFY;
              else cache_state <= IDLE;
            end else begin
              o_mem_address <= cache.address;
              o_mem_read    <= '1;
            end
          end
          MODIFY: begin
            cache_state <= WRITE;
            case (cache.store_type)
              0: begin  // SW
                data[set_select].words[word_select] <= cache.din;
              end
              1: begin  // SH
                if (byte_select[1]) begin
                  data[set_select].words[word_select][31:16] <= cache.din[15:0];
                end else begin
                  data[set_select].words[word_select][15:0] <= cache.din[15:0];
                end
              end
              2: begin  // SB
                case (byte_select)
                  0: begin
                    data[set_select].words[word_select][7:0] <= cache.din[7:0];
                  end
                  1: begin
                    data[set_select].words[word_select][7:0] <= cache.din[7:0];
                  end
                  2: begin
                    data[set_select].words[word_select][15:8] <= cache.din[7:0];
                  end
                  3: begin
                    data[set_select].words[word_select][23:16] <= cache.din[7:0];
                  end
                  default: begin
                    data[set_select].words[word_select][31:24] <= cache.din[7:0];
                  end
                endcase
              end
              default: data[set_select].words[word_select] <= cache.din;
            endcase
          end
          WRITE: begin
            if (i_mem_done) begin
              cache_state   <= IDLE;
              cache.ready   <= '1;

              o_mem_address <= '0;
              mem_data      <= '0;
              o_mem_write   <= '0;
            end else begin
              o_mem_address <= cache.address;
              mem_data      <= data[set_select].words;
              o_mem_write   <= '1;
            end
          end
          default: cache_state <= IDLE;
        endcase
      end
    end
  end  // data_load_and_modify
endmodule
