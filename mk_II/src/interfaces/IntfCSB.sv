// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfCSB;  // Common Signal Bus
  logic clock, reset, delete_tag, clear_tag;

  modport notag(input clock, reset);
  modport tag(input clock, reset, delete_tag, clear_tag);
  modport ReorderBuffer(input clock, reset, output delete_tag, clear_tag);
endinterface
