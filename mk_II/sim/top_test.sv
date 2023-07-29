module top_test #(
    parameter int XLEN = 32
) ();
  logic clk, reset;

  memory_bus_if memory_bus ();
  debug_interface_if debug ();

  localparam int MemorySizeBytes = 128;
  logic [7:0] MemoryData [MemorySizeBytes];

  cpu #(
      .XLEN(XLEN)
  ) cpu (
      .memory_bus(memory_bus),
      .debug(debug),
      .clk(clk),
      .reset(reset)
  );

  ram #(
      .MEM_SIZE_BYTES(128)
  ) ram (
      .memory_bus(memory_bus),
      .clk(clk),
      .reset(reset)
  );

  initial begin
    $readmemh("../../rv32i-tests/hex", MemoryData);
    $finish;
  end

endmodule
