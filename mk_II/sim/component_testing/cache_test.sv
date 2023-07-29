`timescale 1ps / 1ps

import structures::*;

module cache_test ();

  logic clk, reset;

  global_signals_if gsi (
      .clk  (clk),
      .reset(reset)
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
    #10 cache_bus[0].address = 'h59;
    cache_bus[0].read = 1;
    #20 memory_bus.data = {2048{1'h1}};
    memory_bus.ready = 1;
    #20 cache_bus[1].address = 'h63;
    cache_bus[1].write = 1;
    cache_bus[1].data  = 'hdeadbeef;
    #10 cache_bus[1].write = 0;
    #150 $finish;
  end

  always #10 clk <= ~clk;

endmodule
