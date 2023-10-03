import global_variables::XLEN;
import structures::*;

module data_cache #(
    parameter int SETS  = 8,
    parameter int WORDS = 4
) (
    global_bus_if.rest global_bus,
    memory_bus_if.cache memory_bus,
    data_cache_bus_if.cache cache_bus,
    common_data_bus_if.cache data_bus[2]
);
  // ------------------------------- Parameters -------------------------------
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  // ------------------------------- Wires -------------------------------
  logic [SetBits-1:0] set_select;
  logic [WordBits-1:0] word_select;
  logic [1:0] byte_select;

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [XLEN-(SetBits+WordBits+2)-1:0] tag;
    logic [WORDS-1:0][XLEN-1:0] words;
    cache_state_e state;
  } cache_set_t;

  typedef struct packed {
    logic [XLEN-1:0] address;
    logic [WORDS-1:0][XLEN-1:0] words;
  } wb_record_t;

  // ------------------------------- Wires -------------------------------
  cache_set_t data[SETS];
  wb_record_t write_buffer[SETS];

  logic [3:0] read_index;
  logic [3:0] write_index;
  logic read;
  logic empty;

  // ------------------------------- Behaviour -------------------------------
  assign byte_select = cache_bus.address[1:0];
  assign word_select = WORDS - 1 - cache_bus.address[WordBits+1:2];
  assign set_select  = cache_bus.address[SetBits+WordBits+1:WordBits+2];


  always_comb begin : data_reset
    if (global_bus.reset) begin
      foreach (data[j]) begin
        data[j] = '{'z, 'z, INVALID};
      end
    end
  end

  always_comb begin : port_reset
    if (global_bus.reset) begin
      cache_bus.hit = 1'h0;
      memory_bus.read = 1'h0;
      memory_bus.write = 1'h0;
    end
  end

  always_comb begin
    if (cache_bus.read) begin
      if (cache_bus.address[XLEN-1:(SetBits+WordBits+2)] == data[set_select].tag) begin
        cache_bus.hit  = 1'h1;
        cache_bus.data = data[set_select].words[word_select];
      end else if (!(memory_bus.read || memory_bus.write)) begin
        memory_bus.read = 1'h1;
        memory_bus.address = cache_bus.address;
        cache_bus.hit = 1'h0;
      end else if (memory_bus.read && !memory_bus.write && memory_bus.address == cache_bus.address)
        if (memory_bus.ready) begin
          data[set_select].tag = cache_bus.address[XLEN-1:(SetBits+WordBits+2)];
          data[set_select].words = memory_bus.data;
          data[set_select].state = VALID;

          memory_bus.read = 1'h0;
          memory_bus.address = 'z;
        end else cache_bus.hit = 1'h0;
    end else cache_bus.hit = 1'h0;
  end

  always_ff @(posedge global_bus.clock) begin
    if (cache_bus.write) begin
      if (cache_bus.address[XLEN-1:(SetBits+WordBits+2)] == data[set_select].tag
          && data[set_select].state == MODIFIED) begin
        write_buffer[write_index] <= '{
            {data[set_select].tag, set_select, {WordBits + 2{1'h0}}},
            data[set_select].words
        };
        write_index <= write_index + 1;
      end else begin
        data[set_select].tag <= cache_bus.address[XLEN-1:(SetBits+WordBits+2)];
        data[set_select].words[word_select] <= cache_bus.data;
        data[set_select].state <= MODIFIED;
      end
    end
  end

  always_ff @(posedge global_bus.clock) begin
    /*if (!empty && !memory_bus.read) begin
      memory_bus.write <= 1'h1;
      memory_bus.address <= write_buffer[0].address;
      memory_bus.data <= write_buffer[0].words;
    end else if (memory_bus.write && memory_bus.done) begin
      memory_bus.write <= 1'h0;
      read <= 1'h1;
    end else read <= 1'h0;*/
  end

  // Queue control -------------------------------------------------------------------------------

  always_comb begin
    if (global_bus.reset) begin
      foreach (write_buffer[i]) write_buffer[i] = '{{XLEN{1'hz}}, {XLEN * WORDS{1'h0}}};
      read_index  = 8'h00;
      write_index = 8'h00;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (read && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_comb begin
    if (read_index == write_index) empty = 1'h1;
    else empty = 1'h0;
  end
endmodule
