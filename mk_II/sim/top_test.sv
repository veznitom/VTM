module top_test ();
  logic clock, reset;

  localparam int InstrCacheWords = 8;
  localparam int MemorySizeBytes = 256;
  localparam int MemoryBusWidthBytes = (XLEN / 8) * InstrCacheWords;

  memory_bus_if #(.BUS_WIDTH_BYTES(MemoryBusWidthBytes)) memory_bus ();
  memory_debug_if memory_debug ();
  cpu_debug_if cpu_debug ();

  cpu #(
      .INSTR_CACHE_WORDS(InstrCacheWords),
      .INSTR_CACHE_SETS(16),
      .DATA_CACHE_WORDS(2),
      .DATA_CACHE_SETS(16)
  ) cpu (
      .memory_bus(memory_bus),
      .debug(cpu_debug),
      .clock(clock),
      .reset(reset)
  );

  ram #(
      .MEM_SIZE_BYTES(MemorySizeBytes),
      .MEMORY_BUS_WIDTH_BYTES(MemoryBusWidthBytes),
      .MEM_FILE_PATH("reg_zero.mem")
  ) ram (
      .memory_bus(memory_bus),
      .clock(clock),
      .reset(reset)
  );

  initial begin
    clock = 0;
    reset = 0;
    #10 reset = 1;
    #10 reset = 0;
    #1000 $finish;
  end

  always #10 clock = ~clock;

endmodule
