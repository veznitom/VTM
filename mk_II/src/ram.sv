module ram #(
    parameter int XLEN = 32,
    parameter int MEM_SIZE_BYTES = 8192,
    parameter int ADDRESS_WIDTH = $clog2(MEM_SIZE_BYTES),
    parameter string MEM_FILE_PATH = ""
) (
    memory_bus_if memory_bus,

    input logic clock,
    input logic reset
);
  typedef logic [memory_bus.BUS_WIDTH_BITS-1:0] memory_bus_data_t;
  logic [7:0] data[MEM_SIZE_BYTES];

  logic [XLEN-1:0] start_address, end_address;

  always_comb begin
    if (reset) begin
      $readmemh(MEM_FILE_PATH, data);
    end
  end

  assign start_address = memory_bus.address[ADDRESS_WIDTH-1:0] &
    {{(ADDRESS_WIDTH-memory_bus.BUS_BIT_LOG){1'h1}}, {memory_bus.BUS_BIT_LOG{1'h0}}};
  assign end_address = memory_bus.address[ADDRESS_WIDTH-1:0] | {memory_bus.BUS_BIT_LOG{1'h1}};

  always_ff @(posedge clock) begin
    if (memory_bus.read) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTES; i++)
      memory_bus.data <= memory_bus_data_t'(data[start_address+:memory_bus.BUS_WIDTH_BYTES]);
      memory_bus.ready <= 1'h1;
    end else if (memory_bus.write) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTES; i++)
      data[memory_bus.address[ADDRESS_WIDTH-1:0]+i] <= memory_bus.data[i];
      memory_bus.done <= 1'h1;
    end else begin
      memory_bus.ready <= 1'h0;
      memory_bus.done  <= 1'h0;
    end
  end

endmodule
