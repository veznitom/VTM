// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfRegValBus;
  logic [31:0] data_1, data_2;
  logic [5:0] src_1, src_2;
  logic valid_1, valid_2;

  modport Comparator(
      input data_1, data_2, valid_1, valid_2,
      output src_1, src_2
  );
  modport RegisterFile(
      input src_1, src_2,
      output data_1, data_2, valid_1, valid_2
  );
endinterface
