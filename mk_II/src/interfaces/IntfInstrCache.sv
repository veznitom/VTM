// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfInstrCache;
  logic [31:0] address, instruction;
  logic read, hit;

  modport InstructionCache(input address, read, output instruction, hit);
  modport Loader(input instruction, hit, output address, read);
endinterface  //ifc_instr_cache
