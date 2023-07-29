import structures::*;

module cache #(
    parameter int XLEN  = 32,
    parameter int SETS  = 8,
    parameter int WORDS = 4,
    parameter int PORTS = 2
) (
    global_signals_if.rest gsi,

    cache_bus_if.cache cache_bus[PORTS],
    cache_memory_bus_if.cache memory_bus,
    common_data_bus_if.cache cdb[2]
);
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  logic [SetBits-1:0] set_select[PORTS];
  logic [WordBits-1:0] word_select[PORTS];
  logic [1:0] byte_select[PORTS];

  typedef struct packed {
    logic [XLEN-(SetBits+WordBits+2)-1:0] tag;
    logic [WordBits-1:0][XLEN-1:0] words;
    cache_state_e state;
  } cache_set_t;

  typedef struct packed {
    logic [XLEN-1:0] address;
    logic [WordBits-1:0][XLEN-1:0] words;
  } wb_record_t;

  cache_set_t data[SETS];

  wb_record_t write_buffer[$:SETS];

  always_comb begin : data_reset
    if (gsi.reset) begin
      foreach (data[j]) begin
        data[j] = '{'z, 'z, INVALID};
      end
    end
  end

  genvar i;
  generate
    for (i = 0; i < PORTS; i++) begin : g_

      always_comb begin : port_reset
        if (gsi.reset) begin
          cache_bus[i].hit = 0;
        end
      end

      always_ff @(posedge gsi.clk) begin
        if (cache_bus[i].read) begin
          if (cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)] == data[set_select[i]].tag) begin
            cache_bus[i].hit  <= 1'h1;
            cache_bus[i].data <= data[set_select[i]].words[word_select[i]];
          end else if (!(memory_bus.read || memory_bus.write)) begin
            memory_bus.read <= 1'h1;
            memory_bus.address <= cache_bus[i].address;
            cache_bus[i].hit <= 1'h0;
          end else if (memory_bus.read && !memory_bus.write &&
          memory_bus.address == cache_bus[i].address)
            if (memory_bus.ready) begin
              data[set_select[i]].tag <= cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
              data[set_select[i]].words <= memory_bus.data;
              data[set_select[i]].state <= VALID;

              memory_bus.read <= 1'h0;
              memory_bus.address <= 'z;
            end else cache_bus[i].hit <= 1'h0;
        end
      end

      always_ff @(posedge gsi.clk) begin
        if (cache_bus[i].write) begin
          if (data[set_select[i]].state == MODIFIED) begin
            write_buffer.push_back('{{data[set_select[i]].tag, set_select[i], {WordBits + 2{1'h0}}},
                                   data[set_select[i]].words});
          end else begin
            data[set_select[i]].tag <= cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
            data[set_select[i]].words[word_select[i]] <= cache_bus[i].data;
            data[set_select[i]].state <= MODIFIED;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge gsi.clk) begin
    if (write_buffer.size() != 0 && !memory_bus.read) begin
      memory_bus.write <= 1'h1;
      memory_bus.address <= write_buffer[0].address;
      memory_bus.data <= write_buffer[0].words;
    end
    if (memory_bus.write && memory_bus.done) begin
      memory_bus.write <= 1'h0;
      write_buffer.pop_front();
    end
  end

endmodule
