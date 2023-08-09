module top #(
    parameter int XLEN  = 32,
    parameter int WORDS = 4
) ();
  logic clock, reset;

  memory_bus_if #(.BUS_WIDTH_BYTES((XLEN / 8) * WORDS)) memory_bus ();
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
endmodule
