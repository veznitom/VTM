// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfRegQuery;
  registers_t input_regs[2], output_regs[2];
  logic rename[2], tag[2];

  modport IPWrapper(input output_regs, output input_regs, rename, tag);
  modport RegisterFile(input input_regs, rename, tag, output output_regs);
endinterface

