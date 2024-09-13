// Copyright (c) 2024 veznitom
/*
interface IntfMemory ();
  wire  [255:0] data;
  logic [ 31:0] address;
  logic read, write, ready, done;

  modport Cache(input ready, done, inout data, output address, read, write);
  modport MMU(input read, write, address, inout data, output ready, done);
  modport RAM(input address, read, write, inout data, output ready, done);
  modport CPU(input ready, done, inout data, output address, read, write);
endinterface
*/