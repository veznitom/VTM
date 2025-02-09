// Copyright (c) 2024 veznitom

interface IntfMemory ();
  tri   [31:0][7:0] data;
  logic [31:0]      address;
  logic read, ready;
  logic write, done;

  modport InstrCache(input data, ready, output address, read);
  modport DataCache(input ready, done, inout data, output address, read, write);
  modport RAM(input address, read, write, inout data, output ready, done);
endinterface
