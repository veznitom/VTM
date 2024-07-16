// Copyright (c) 2024 veznitom

`default_nettype none
interface ifc_data_cache;
  logic [31:0] address;
  logic [31:0] data;
  logic read, write, hit, ready;

  modport cache(input address, read, write, inout data, output hit, ready);
  modport load_store(input hit, ready, inout data, output address, read, write);
endinterface  //ifc_data_cache
