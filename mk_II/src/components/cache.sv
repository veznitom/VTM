import structures::*;

module cache #(
    parameter int XLEN  = 32,
    parameter int SETS  = 8,
    parameter int WORDS = 4,
    parameter int PORTS = 1
) (
    global_bus_if.rest global_bus,

    memory_bus_if.cache_cpu cpu_bus[PORTS],
    memory_bus_if.cache_mem memory_bus,
    common_data_bus_if.cache data_bus[2]
);
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  logic [SetBits-1:0] set_select[PORTS];
  logic [WordBits-1:0] word_select[PORTS];
  logic [1:0] byte_select[PORTS];

  typedef struct packed {
    logic [XLEN-(SetBits+WordBits+2)-1:0] tag;
    logic [WORDS-1:0][XLEN-1:0] words;
    cache_state_e state;
  } cache_set_t;

  typedef struct packed {
    logic [XLEN-1:0] address;
    logic [WORDS-1:0][XLEN-1:0] words;
  } wb_record_t;

  cache_set_t data[SETS];

  wb_record_t write_buffer[$:SETS];

  genvar i;
  generate
    for (i = 0; i < PORTS; i++) begin : gen_selects
      assign byte_select[i] = cpu_bus[i].address[1:0];
      assign word_select[i] = cpu_bus[i].address[WordBits+1:2];
      assign set_select[i]  = cpu_bus[i].address[SetBits+WordBits+1:WordBits+2];
    end
  endgenerate

  always_comb begin : data_reset
    if (global_bus.reset) begin
      foreach (data[j]) begin
        data[j] = '{'z, '{'z, 'z, 'z, 'z}, INVALID};
      end
    end
  end

  generate
    for (i = 0; i < PORTS; i++) begin : gen_per_port

      always_comb begin : port_reset
        if (global_bus.reset) begin
          cpu_bus[i].hit   = 0;
          memory_bus.read  = 0;
          memory_bus.write = 0;
        end
      end

      always_ff @(posedge global_bus.clock) begin
        if (cpu_bus[i].read) begin
          if (cpu_bus[i].address[XLEN-1:(SetBits+WordBits+2)] == data[set_select[i]].tag) begin
            cpu_bus[i].hit  <= 1'h1;
            cpu_bus[i].data <= data[set_select[i]].words[word_select[i]];
          end else if (!(memory_bus.read || memory_bus.write)) begin
            memory_bus.read <= 1'h1;
            memory_bus.address <= cpu_bus[i].address;
            cpu_bus[i].hit <= 1'h0;
          end else if (memory_bus.read && !memory_bus.write &&
          memory_bus.address == cpu_bus[i].address)
            if (memory_bus.ready) begin
              data[set_select[i]].tag <= cpu_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
              data[set_select[i]].words <= memory_bus.data;
              data[set_select[i]].state <= VALID;

              memory_bus.read <= 1'h0;
              memory_bus.address <= 'z;
            end else cpu_bus[i].hit <= 1'h0;
        end
      end

      always_ff @(posedge global_bus.clock) begin
        if (cpu_bus[i].write) begin
          if (cpu_bus[i].address[XLEN-1:(SetBits+WordBits+2)] == data[set_select[i]].tag
          && data[set_select[i]].state == MODIFIED) begin
            write_buffer.push_back('{{data[set_select[i]].tag, set_select[i], {WordBits + 2{1'h0}}},
                                   data[set_select[i]].words});
          end else begin
            data[set_select[i]].tag <= cpu_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
            data[set_select[i]].words[word_select[i]] <= cpu_bus[i].data;
            data[set_select[i]].state <= MODIFIED;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin
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
