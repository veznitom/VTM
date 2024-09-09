// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfRegQuery;
  registers_t inputs, outputs;
  logic [1:0] rename_status;
  logic rename, tag;

  modport IPWrapper(input outputs, output inputs, rename, tag);
  modport Resolver(input outputs);
  modport Renamer(output inputs, rename, tag, input rename_status);
  modport RegisterFile(input inputs, rename, tag, output outputs);
endinterface

