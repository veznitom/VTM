`timescale 1ps/1ps

import structures::*;

module cache_test ();

  logic clk, reset;

  global_signals_if gsi (
      clk,
      reset
  );

  cache_bus_if cache_bus[2] ();
  cache_memory_bus_if memory_bus ();
  common_data_bus_if cdb[2] ();

  cache cache (
      .gsi(gsi),
      .cache_bus(cache_bus),
      .memory_bus(memory_bus),
      .cdb(cdb)
  );

  initial begin
    clk   = 0;
    reset = 1;
    #20 reset = 0;
    #10 cache_bus[0].address = 10;
    cache_bus[0].read = 1;
    #100 $finish;
  end

  always #10 clk <= ~clk;

endmodule
