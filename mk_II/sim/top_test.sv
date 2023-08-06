module top_test #(
    parameter int XLEN = 32
) ();
  logic clock, reset;

  memory_bus_if memory_bus ();
  memory_debug_if memory_debug ();
  cpu_debug_if cpu_debug ();

  localparam int MemorySizeBytes = 256;

  cpu #(
      .XLEN(XLEN)
  ) cpu (
      .memory_bus(memory_bus),
      .debug(cpu_debug),
      .clock(clock),
      .reset(reset)
  );

  ram #(
      .MEM_SIZE_BYTES(MemorySizeBytes),
      .MEM_FILE_PATH ("/home/tomasv/Projects/VTM/custom-tests/reg_file_clear.hex")
  ) ram (
      .memory_bus(memory_bus),
      .clock(clock),
      .reset(reset)
  );

  initial begin
    clock = 0;
    reset = 1;
    #40;
    reset = 0;
    #100 $finish;
  end

  always #10 clock = ~clock;

endmodule
