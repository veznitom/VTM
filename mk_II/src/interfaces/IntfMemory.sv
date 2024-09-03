// Copyright (c) 2024 veznitom

interface IntfMemory #(
  parameter int BUS_WIDTH_BYTES = 256
) ();
  wire [(BUS_WIDTH_BYTES * 8) - 1:0] data;
  wire [                       31:0] address;
  logic read, write, ready, done;

  modport Cache(input ready, done, inout data, output address, read, write);
  modport MMU(input read, write, inout data, address, output ready, done);
  modport RAM(input address, read, write, inout data, output ready, done);
  modport CPU(input ready, done, inout data, output address, read, write);
endinterface
