// Manages loading instructions from instr cache, if there is cache miss padds output instructions with zeroes
import global_variables::XLEN;

module loader (
    global_bus_if.rest global_bus,
    pc_bus_if.loader pc_bus,
    instr_cache_bus_if.loader cache_bus[2],

    output logic [XLEN-1:0] address[2],
    output logic [31:0] instr[2],
    input logic stop
);
  always_comb begin : pc_bus_reset
    if (global_bus.reset) begin
      pc_bus.plus_4 = 1'h0;
      pc_bus.plus_8 = 1'h0;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_var_reset
      always_comb begin
        if (global_bus.reset) begin
          address[i] = {XLEN{1'h0}};
          instr[i] = {32{1'h0}};
          cache_bus[i].read = 1'h1;
        end
      end
    end
  endgenerate

  always_ff @(global_bus.clock) begin : instr_load
    if (global_bus.clock)
      if (!stop && cache_bus[0].hit && cache_bus[1].hit) begin
        address[0] <= cache_bus[0].address;
        instr[0] <= cache_bus[0].instr;
        address[1] <= cache_bus[1].address;
        instr[1] <= cache_bus[1].instr;
        pc_bus.plus_8 <= 1'h1;
      end else begin
        address[0] <= {XLEN{1'h0}};
        instr[0] <= {32{1'h0}};
        address[1] <= {XLEN{1'h0}};
        instr[1] <= {32{1'h0}};
        pc_bus.plus_8 <= 1'h0;
      end
    else pc_bus.plus_8 <= 1'h0;
  end
endmodule
