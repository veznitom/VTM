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
  // ------------------------------- Parameters -------------------------------
  localparam int SetBits = $clog2(SETS);
  localparam int WordBits = $clog2(WORDS);

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [XLEN-(SetBits+WordBits+2)-1:0] tag;
    logic [WORDS-1:0][XLEN-1:0] words;
    cache_state_e state;
  } cache_set_t;

  // ------------------------------- Wires -------------------------------
  logic [SetBits-1:0] set_select[2];
  logic [WordBits-1:0] word_select[2];
  logic [1:0] byte_select[2];
  bit miss[2];
  cache_set_t data[SETS];
  // ------------------------------- Behaviour -------------------------------
  always_comb begin : data_reset
    if (global_bus.reset) begin
      foreach (data[j]) begin
        data[j] = '{'0, '0, INVALID};
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
        if (global_bus.reset) begin
          cache_bus[i].instr = '0;
          cache_bus[i].hit = 1'h0;
          miss[i] = 1'b0;
        end
      end

      always_ff @(global_bus.clock) begin : cache_read
        if (cache_bus[i].read) begin
          if ((cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)] == data[set_select[i]].tag) &&
              (data[set_select[i]].state == VALID)) begin
            miss[i] <= 1'h0;
            cache_bus[i].hit <= 1'h1;
            cache_bus[i].instr <= data[set_select[i]].words[word_select[i]];
          end else begin
            miss[i] <= 1'h1;
            cache_bus[i].hit <= 1'h0;
          end
        end else cache_bus[i].hit <= 1'h0;
      end

      always_ff @(posedge global_bus.clock) begin : miss_mem_fetch
        if (miss[i] && (!memory_bus.read || memory_bus.address == cache_bus[i].address)) begin
          if (memory_bus.ready) begin
            memory_bus.read <= 1'h0;
            memory_bus.address <= {XLEN{1'h0}};

            data[set_select[i]].tag <= cache_bus[i].address[XLEN-1:(SetBits+WordBits+2)];
            data[set_select[i]].words <= memory_bus.data;
            data[set_select[i]].state <= VALID;
          end else begin
            memory_bus.read <= 1'h1;
            memory_bus.address <= cache_bus[i].address;
          end
        end
      end
    end
  endgenerate
endmodule
