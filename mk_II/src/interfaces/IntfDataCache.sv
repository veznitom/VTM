// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfDataCache;
  tri   [31:0] data;
  logic [31:0] address;
  logic read, hit;
  logic write, done;
  logic tag;

  modport DataCache(
      input address, read, write, tag,
      inout data,
      output hit, done
  );
  modport LoadStore(
      input hit, done,
      inout data,
      output address, read, write, tag
  );
endinterface
