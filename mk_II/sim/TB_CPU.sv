// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module TB_CPU ();
  bit clock, reset;

  IntfMemory u_memory_bus ();

  CPU u_cpu (
    .i_clock   (clock),
    .i_reset   (reset),
    .memory_bus(u_memory_bus)
  );

  RAM #(
    .MEM_SIZE_BYTES(4096),
    .MEM_FILE_PATH ("/home/tomasv/Projects/VTM/mk_II/sw/hex/load-b.hex")
  ) u_ram (
    .i_clock(clock),
    .i_reset(reset),
    .memory_bus (u_memory_bus)
  );

  assign #10 clock = ~clock;

  initial begin
    reset = '1;
    #200 reset = '0;
    #1800 $finish;
  end

endmodule
