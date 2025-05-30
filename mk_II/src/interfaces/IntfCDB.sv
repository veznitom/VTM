// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfCDB;  // Common Data Bus
  wire [31:0] result, address, result_address;
  wire [5:0] arn, rrn;
  wire [7:0] select;
  wire reg_write, cache_write;

  modport Combo(
      inout result, address, result_address, select, arn,
      output rrn, reg_write
  );
  modport ReorderBuffer(
      inout result, address, result_address, arn, rrn, select,
      output reg_write, cache_write
  );
  modport RegisterFile(input result, address, arn, rrn, reg_write);
  modport Cache(input result, address, cache_write);
  modport Comparator(input result, arn, rrn);
endinterface
