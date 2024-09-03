// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfRegQuery;
  registers_t inputs, outputs;
  logic rename, tag;

  modport Resolver(input outputs);
  modport Renamer(output inputs, rename, tag);
  modport RegisterFile(input inputs, rename, tag, output outputs);
endinterface

