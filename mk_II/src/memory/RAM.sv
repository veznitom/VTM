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
  // ------------------------------- Wires --------------------------------
  logic [ 7:0]      data          [MEM_SIZE_BYTES];
  logic [31:0]      start_address;
  logic [31:0][7:0] tmp_data;
  logic ready, done;

  int i;

  // ------------------------------- Behaviour -------------------------------
  assign memory_bus.ready = ready;
  assign memory_bus.done  = done;
  assign memory_bus.data  = memory_bus.read ? tmp_data : 'z;
  assign start_address    = {memory_bus.address[31:3], 3'h0};

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      $readmemh(MEM_FILE_PATH, data);
      ready    <= 1'h0;
      done     <= 1'h0;
      tmp_data <= '0;
    end else if (memory_bus.read) begin
      for (i = 0; i < 32; i++) begin
        tmp_data[i] <= data[start_address+i];
      end
      ready <= 1'h1;
      done  <= 1'h0;
    end else if (memory_bus.write) begin
      for (i = 0; i < 32; i++) begin
        data[start_address+i] <= memory_bus.data[i];
      end
      ready <= 1'h0;
      done  <= 1'h1;
    end else begin
      ready <= 1'h0;
      done  <= 1'h0;
    end
  end

endmodule
