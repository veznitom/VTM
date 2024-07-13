import pkg_structures::*;

module cache_data #(
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
    logic [WORDS-1:0][31:0] words;
    cache_state_e state;
  } cache_set_t;

  typedef struct packed {
    logic [31:0] address;
    logic [WORDS-1:0][31:0] words;
  } wb_record_t;

  // ------------------------------- Wires -------------------------------
  cache_set_t data[SETS];
  wb_record_t write_buffer[SETS];
  logic [3:0] read_index, write_index;
  logic read, empty, miss, write_back;

  // ------------------------------- Behaviour -------------------------------
  assign byte_select = cache_bus.address[1:0];
  assign word_select = WORDS - 1 - cache_bus.address[WordBits+1:2];
  assign set_select  = cache_bus.address[SetBits+WordBits+1:WordBits+2];


  always_comb begin : data_reset
    if (global_bus.reset) begin
      foreach (data[j]) begin
        data[j] = '{'0, '0, INVALID};
      end
      miss = 1'h0;
      write_back = 1'h0;
    end
  end

  always_comb begin : port_reset
    if (global_bus.reset) begin
      cache_bus.hit = 1'h0;
      memory_bus.address = '0;
      memory_bus.data = '0;
      memory_bus.read = 1'h0;
      memory_bus.write = 1'h0;
    end
  end

  always_ff @(posedge global_bus.clock) begin : cache_read
    if (cache_bus.read && !write_back) begin
      if ((cache_bus.address[31:(SetBits+WordBits+2)] == data[set_select].tag) &&
          (data[set_select].state == VALID)) begin
        miss <= 1'h0;
        cache_bus.hit <= 1'h1;
        cache_bus.data <= data[set_select].words[word_select];
      end else begin
        miss <= 1'h1;
        cache_bus.hit <= 1'h0;
      end
    end else cache_bus.hit <= 1'h0;
  end

  always_ff @(posedge global_bus.clock) begin : miss_mem_fetch
    if (miss && !write_back) begin
      if (memory_bus.ready) begin
        memory_bus.read <= 1'h0;
        memory_bus.address <= {XLEN{1'h0}};

        data[set_select].tag <= cache_bus.address[31:(SetBits+WordBits+2)];
        data[set_select].words <= memory_bus.data;
        data[set_select].state <= VALID;
      end else begin
        memory_bus.read <= 1'h1;
        memory_bus.address <= cache_bus.address;
      end
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (cache_bus.write && !write_back) begin
      if (cache_bus.address[31:(SetBits+WordBits+2)] == data[set_select].tag &&
          data[set_select].state == MODIFIED) begin
        write_buffer[write_index] <= '{
            {data[set_select].tag, set_select, {WordBits + 2{1'h0}}},
            data[set_select].words
        };
        write_index <= write_index + 1;
      end
      data[set_select].tag <= cache_bus.address[31:(SetBits+WordBits+2)];
      data[set_select].words[word_select] <= cache_bus.data;
      data[set_select].state <= MODIFIED;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (write_back) begin
      if (memory_bus.done) begin
        memory_bus.write <= 1'h0;
        memory_bus.address <= '0;
        memory_bus.data <= '0;

        write_back <= 1'h0;
        read <= 1'h1;
      end else begin
        memory_bus.write <= 1'h1;
        memory_bus.address <= write_buffer[0].address;
        memory_bus.data <= write_buffer[0].words;

        read <= 1'h0;
      end
    end else if (empty) begin
      write_back <= 1'h0;
      read <= 1'h0;
    end else if (!empty && !memory_bus.read && memory_bus.write) begin
      write_back <= 1'h1;
      read <= 1'h0;
    end else read <= 1'h0;
  end

  // Queue control -------------------------------------------------------------------------------

  always_comb begin
    if (global_bus.reset) begin
      foreach (write_buffer[i]) write_buffer[i] = '{{XLEN{1'h0}}, {XLEN * WORDS{1'h0}}};
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
