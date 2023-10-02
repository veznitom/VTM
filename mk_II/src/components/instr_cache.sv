import global_variables::XLEN;
import structures::*;

module instr_cache #(
    parameter int SETS  = 8,
    parameter int WORDS = 4
) (
    global_bus_if.rest global_bus,
    memory_bus_if.cache memory_bus,
    instr_cache_bus_if.cache cache_bus[2]
);
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  logic [SetBits-1:0] set_select[2];
  logic [WordBits-1:0] word_select[2];
  logic [1:0] byte_select[2];

  typedef struct packed {
    logic [XLEN-(SetBits+WordBits+2)-1:0] tag;
    logic [WORDS-1:0][XLEN-1:0] words;
    cache_state_e state;
  } cache_set_t;

  cache_set_t data[SETS];

  always_comb begin : data_reset
    if (global_bus.reset) begin
      foreach (data[j]) begin
        data[j] = '{'z, 'z, INVALID};
      end
      memory_bus.read  = 1'h0;
      memory_bus.write = 1'h0;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_selects
      assign byte_select[i] = cache_bus[i].address[1:0];
      assign word_select[i] = WORDS - 1 - cache_bus[i].address[WordBits+1:2];
      assign set_select[i]  = cache_bus[i].address[SetBits+WordBits+1:WordBits+2];

      always_comb begin : port_reset
        if (global_bus.reset) cache_bus[i].hit = 1'h0;
      end

      always_comb  /*always_ff @(posedge global_bus.clock)*/ begin
        if (cache_bus[i].read) begin
          if (cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)] == data[set_select[i]].tag) begin
            cache_bus[i].hit  = 1'h1;
            cache_bus[i].instr = data[set_select[i]].words[word_select[i]];
          end else if (!(memory_bus.read || memory_bus.write)) begin
            memory_bus.read = 1'h1;
            memory_bus.address = cache_bus[i].address;
            cache_bus[i].hit = 1'h0;
          end else if (memory_bus.read && !memory_bus.write &&
          memory_bus.address == cache_bus[i].address)
            if (memory_bus.ready) begin
              data[set_select[i]].tag = cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
              data[set_select[i]].words = memory_bus.data;
              data[set_select[i]].state = VALID;

              memory_bus.read = 1'h0;
              memory_bus.address = 'z;
            end else cache_bus[i].hit = 1'h0;
        end else cache_bus[i].hit = 1'h0;
      end
    end
  endgenerate
endmodule
