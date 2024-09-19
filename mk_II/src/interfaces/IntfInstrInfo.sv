// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfInstrInfo;
  logic [31:0] address, immediate;
  instr_name_e  instr_name;
  instr_type_e  instr_type;
  registers_t   regs;
  flag_vector_t flags;

  modport In(input address, immediate, instr_name, regs, instr_type, flags);
  modport Out(
      output address, immediate, instr_name, regs, instr_type, flags,
      import clear
  );

  task automatic clear();
    address    = '0;
    immediate  = '0;
    instr_name = UNKNOWN;
    regs       = '{0, 0, 0, 0};
    instr_type = XX;
    flags      = '{0, 0, 0, 0, 0};
  endtask  //automatic
endinterface
