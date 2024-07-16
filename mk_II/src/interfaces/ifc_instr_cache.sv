// Copyright (c) 2024 veznitom

`default_nettype none
interface ifc_instr_cache;
  logic [31:0] address, instruction;
  logic read, hit;

  modport cache(input address, read, output instruction, hit);
  modport loader(input instruction, hit, output address, read);
endinterface  //ifc_instr_cache
