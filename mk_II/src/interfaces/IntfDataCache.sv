// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfDataCache;
  logic [ 3:0][7:0] rd_data;
  logic [ 3:0][7:0] wr_data;
  logic [31:0]      address;
  logic [ 3:0]      write_select;
  logic read, hit;
  logic write, done;
  logic tag;

  modport DataCache(
      input address, read, write, tag, write_select, wr_data,
      output hit, done, rd_data
  );
  modport LoadStore(
      input hit, done, rd_data,
      output address, read, write, tag, write_select, wr_data
  );
endinterface
