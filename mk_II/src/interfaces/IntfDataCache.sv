// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfDataCache;
  tri   [31:0] data;
  logic [31:0] address;
  logic [ 1:0] store_type;
  logic read, hit;
  logic write, done;
  logic tag;

  modport DataCache(
      input address, read, write, store_type, tag,
      inout data,
      output hit, done
  );
  modport LoadStore(
      input hit, done,
      inout data,
      output address, read, write, store_type, tag
  );
endinterface
