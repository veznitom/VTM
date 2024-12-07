// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module RAM #(
  parameter int    MEM_SIZE_BYTES = 1024,
  parameter string MEM_FILE_PATH  = ""
) (
  input logic i_clock,
  input logic i_reset,

  input  logic [ 31:0] i_address,
  input  logic         i_read,
  input  logic         i_write,
  inout  wire  [255:0] io_data,
  output logic         o_ready,
  output logic         o_done
);
  typedef struct packed {logic [255:0] data;} pack_t;
  // ------------------------------- Wires --------------------------------
  logic [  7:0] data          [MEM_SIZE_BYTES];
  logic [ 31:0] start_address;
  logic [255:0] tmp_data;
  int file, instr_load, index, ready;

  // ------------------------------- Behaviour -------------------------------
  assign o_ready       = ready;
  assign io_data       = ready ? tmp_data : 'z;
  assign start_address = {i_address[31:3], 3'h0};

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      foreach (data[i]) data[i] = '0;
      $readmemh(MEM_FILE_PATH, data);
      o_done <= 1'h0;
      ready  <= 1'h0;
    end else if (i_read) begin
      for (int i = 0; i < 32; i++) begin
        tmp_data <= pack_t'(data[start_address+:32]);
      end
      ready <= 1'h1;
    end else if (i_write) begin
      for (int i = 0; i < 32; i++) begin
        data[start_address+i] <= io_data[i];
      end
      o_done <= 1'h1;
    end else begin
      ready  <= 1'h0;
      o_done <= 1'h0;
    end
  end

endmodule
