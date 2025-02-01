// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfDataCache;
  logic [31:0] address, din, dout;
  logic [1:0] store_type;
  logic read, hit, write, ready, tag;

  modport DataCache(
      input din, address, read, write, store_type, tag,
      output dout, hit, ready
  );
  modport LoadStore(
      input din, hit, ready,
      output dout, address, read, write, store_type, tag
  );
endinterface
