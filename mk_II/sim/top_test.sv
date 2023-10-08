module top_test #(
    parameter int WORDS = 4
) ();
  logic clock, reset;

  memory_bus_if #(.BUS_WIDTH_BYTES((XLEN / 8) * WORDS)) memory_bus ();
  memory_debug_if memory_debug ();
  cpu_debug_if cpu_debug ();

  localparam int MemorySizeBytes = 256;

  cpu cpu (
      .memory_bus(memory_bus),
      .debug(cpu_debug),
      .clock(clock),
      .reset(reset)
  );

  ram #(
      .MEM_SIZE_BYTES(MemorySizeBytes),
      .MEM_FILE_PATH ("reg_zero.mem")
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
    #300 $finish;
  end

  always #10 clock = ~clock;

endmodule
