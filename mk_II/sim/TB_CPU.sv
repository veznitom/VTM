// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module TB_CPU ();
  bit clock, reset;

  wire [255:0] data;
  wire [ 31:0] address;
  wire read, write, ready, done;

  CPU u_cpu (
    .i_clock      (clock),
    .i_reset      (reset),
    .i_mem_ready  (ready),
    .i_mem_done   (done),
    .io_mem_data  (data),
    .o_mem_address(address),
    .o_mem_read   (read),
    .o_mem_write  (write)
  );

  RAM #(
    .MEM_SIZE_BYTES(1024),
    .MEM_FILE_PATH ("/home/tomasv/Projects/VTM/mk_II/sim/reg_zero.mem")
  ) u_ram (
    .i_clock  (clock),
    .i_reset  (reset),
    .i_address(address),
    .i_read   (read),
    .i_write  (write),
    .io_data  (data),
    .o_ready  (ready),
    .o_done   (done)
  );

  assign #10 clock = ~clock;

  initial begin
    reset = '1;
    #200 reset = '0;
    #1200 $finish;
  end

endmodule
