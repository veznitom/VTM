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
  int file, instr_load, index;

  // ------------------------------- Behaviour -------------------------------
  assign memory_bus.data = memory_bus.ready ? tmp_data : 'z;

  always_comb begin
    if (i_reset) begin
      // $readmemh(MEM_FILE_PATH, data);
      file  = $fopen(MEM_FILE_PATH, "r");
      index = 0;
      foreach (data[i]) data[i] = 0;
      while ($fscanf(
          file, "%h", instr_load
      ) == 1) begin
        data[index+3] = instr_load[7:0];
        data[index+2] = instr_load[15:8];
        data[index+1] = instr_load[23:16];
        data[index+0] = instr_load[31:24];
        index += 4;
      end

      memory_bus.done  = 1'h0;
      memory_bus.ready = 1'h0;
    end
  end

  assign start_address = {memory_bus.address[31:3], 3'h0};

  always_ff @(posedge i_clock) begin
    if (memory_bus.read) begin
      for (int i = 0; i < 32; i++) begin
        tmp_data <= pack_t'(data[start_address+:32]);
      end
      memory_bus.ready <= 1'h1;
    end else if (memory_bus.write) begin
      for (int i = 0; i < 32; i++) begin
        data[start_address+i] <= memory_bus.data[i];
      end
      memory_bus.done <= 1'h1;
    end else begin
      memory_bus.ready <= 1'h0;
      memory_bus.done  <= 1'h0;
    end
  end

endmodule
