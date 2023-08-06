module top_test #(
    parameter int XLEN = 32
) ();
  logic clk, reset;

  memory_bus_if memory_bus ();
  memory_debug_if memory_debug ();
  cpu_debug_if cpu_debug ();

  localparam int MemorySizeBytes = 128;

  cpu #(
      .XLEN(XLEN)
  ) cpu (
      .memory_bus(memory_bus),
      .debug(debug),
      .clk(clk),
      .reset(reset)
  );

  ram #(
      .MEM_SIZE_BYTES(MemorySizeBytes),
      .MEM_FILE_PATH("")
  ) ram (
      .memory_bus(memory_bus),
      .clk(clk),
      .reset(reset)
  );

  initial begin
    #100 $finish;
  end

endmodule
