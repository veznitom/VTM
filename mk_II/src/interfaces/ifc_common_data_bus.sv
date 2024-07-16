// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface ifc_common_data_bus;
  wire [31:0] result, address, jmp_address;
  wire [5:0] arn, rrn;
  wire [3:0] select;
  logic reg_write, cache_write;

  modport combo(
      input arn,
      inout result, address, jmp_address, select,
      output rrn, reg_write
  );
  modport rob(
      inout result, address, jmp_address, arn, rrn, select,
      output reg_write, cache_write
  );
  modport reg_file(input result, address, arn, rrn, reg_write);
  modport cache(input result, address, cache_write);
  modport cmp(input result, arn, rrn);
endinterface
