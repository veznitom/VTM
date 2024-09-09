// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfInstrCache;
  logic [31:0] address, instr;
  logic read, hit;

  modport InstrCache(input address, read, output instr, hit);
  modport Loader(input instr, hit, output address, read);
endinterface  //ifc_instr_cache
