// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfDataCache;
  logic [31:0] address;
  wire  [31:0] data;
  logic read, write, hit, ready;

  modport DataCache(input address, read, write, inout data, output hit, ready);
  modport LoadStore(input hit, ready, inout data, output address, read, write);
endinterface  //ifc_data_cache
