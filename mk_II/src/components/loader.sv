// Manages loading instructions from instr cache, if there is cache miss padds output instructions with zeroes

module loader #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    pc_bus_if.loader pc_bus,
    memory_bus_if.loader cache_bus[2],

    output logic [XLEN-1:0] address[2],
    output logic [31:0] instr[2],
    input logic stop
);

  always_ff @(posedge global_bus.clock) begin : instr_load
    if (!stop && cache_bus[0].hit && cache_bus[1].hit) begin
      address[0] <= cache_bus[0].address;
      instr[0] <= cache_bus[0].data;
      address[1] <= cache_bus[1].address;
      instr[1] <= cache_bus[1].data;
      pc_bus.plus_8 <= 1'h1;
    end else begin
      pc_bus.plus_8 <= 1'h0;
    end

    if (!stop) begin
      cache_bus[0].read <= 1'h1;
      cache_bus[1].read <= 1'h1;
    end else begin
      cache_bus[0].read <= 1'h0;
      cache_bus[1].read <= 1'h0;
    end
  end
endmodule
