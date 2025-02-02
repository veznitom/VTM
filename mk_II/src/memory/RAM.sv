// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module RAM #(
  parameter int    MEM_SIZE_BYTES = 1024,
  parameter string MEM_FILE_PATH  = ""
) (
  input logic i_clock,
  input logic i_reset,

  IntfMemory.RAM memory_bus
);
  typedef struct packed {logic [255:0] data;} pack_t;
  // ------------------------------- Wires --------------------------------
  logic [  7:0] data          [MEM_SIZE_BYTES];
  logic [ 31:0] start_address;
  logic [255:0] tmp_data;
  int file, index;
  logic ready;

  // ------------------------------- Behaviour -------------------------------
  assign memory_bus.ready = ready;
  assign memory_bus.data  = ready ? tmp_data : 'z;
  assign start_address    = {memory_bus.address[31:3], 3'h0};

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      foreach (data[i]) data[i] = '0;
      $readmemh(MEM_FILE_PATH, data);
      memory_bus.done <= 1'h0;
      ready           <= 1'h0;
      tmp_data        <= '0;
    end else if (memory_bus.read) begin
      for (int i = 8; i <= 256; i += 8) begin
        tmp_data[(i-1)-:8] <= data[start_address+(i/8)-1];
      end
      ready <= 1'h1;
    end else if (memory_bus.write) begin
      for (int i = 8; i <= 256; i += 8) begin
        data[start_address+(i/8)-1] <= memory_bus.data[(i-1)-:8];
      end
      memory_bus.done <= 1'h1;
    end else begin
      ready           <= 1'h0;
      memory_bus.done <= 1'h0;
    end
  end

endmodule
