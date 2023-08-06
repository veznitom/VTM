module ram #(
    parameter int MEM_SIZE_BYTES = 8192,
    parameter int ADDRESS_WIDTH = $clog2(MEM_SIZE_BYTES),
    parameter string MEM_FILE_PATH = ""
) (
    memory_bus_if memory_bus,
    input logic clk,
    input logic reset
);

  logic [7:0] data[MEM_SIZE_BYTES];

  always_comb begin
    if (reset) begin
      
    end
  end

  always_ff @(posedge clk) begin
    if (memory_bus.read) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTE; i++)
      memory_bus.data[i] <= data[memory_bus.address[ADDRESS_WIDTH-1:0]+i];
      memory_bus.ready <= 1'h1;
    end else if (memory_bus.write) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTE; i++)
      data[memory_bus.address[ADDRESS_WIDTH-1:0]+i] <= memory_bus.data[i];
      memory_bus.done <= 1'h1;
    end else begin
      memory_bus.ready <= 1'h0;
      memory_bus.done  <= 1'h0;
    end
  end

endmodule
