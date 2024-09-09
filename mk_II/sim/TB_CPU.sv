// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module TB_CPU ();
  bit clock, reset;

  IntfMemory u_memory_bus ();

  CPU u_cpu (
    .i_clock(clock),
    .i_reset(reset),
    .memory (u_memory_bus)
  );

  RAM #(
    .MEM_SIZE_BYTES(1024),
    .MEM_FILE_PATH ("reg_zero.mem")
  ) u_ram (
    .i_clock   (clock),
    .i_reset   (reset),
    .memory_bus(u_memory_bus)
  );

  assign #10 clock = ~clock;

  initial begin
    reset = '1;
    #20 reset = '0;
    #500 $finish;
  end

endmodule
