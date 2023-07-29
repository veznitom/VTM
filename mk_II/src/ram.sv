module ram #(
    parameter int MEM_SIZE_BYTES = 8192,
    parameter int ADDRESS_WIDTH = $clog2(MEM_SIZE_BYTES),
    parameter logic [MEM_SIZE_BYTES-1:0][7:0] MEMORY_DATA = {MEM_SIZE_BYTES * 8{1'h0}}
) (
    memory_bus_if memory_bus,
    input clk,
    reset
);

  logic [MEM_SIZE_BYTES-1:0][7:0] data;

  always_comb begin
    if (reset) begin
      data = MEMORY_DATA;
    end
  end

  always_ff @(posedge clk) begin
    if (memory_bus.read) begin
      memory_bus.data  <= data[memory_bus.address[ADDRESS_WIDTH-1:0]-:memory_bus.BUS_WIDTH_BYTE];
      memory_bus.ready <= 1'h1;
    end else if (memory_bus.write) begin
      data[memory_bus.address[ADDRESS_WIDTH-1:0]-:memory_bus.BUS_WIDTH_BYTE] <= memory_bus.data;
      memory_bus.done <= 1'h1;
    end else begin
      memory_bus.ready <= 1'h0;
      memory_bus.done  <= 1'h0;
    end
  end

endmodule
