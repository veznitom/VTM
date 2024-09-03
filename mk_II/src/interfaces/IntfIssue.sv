// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfIssue;
  logic [31:0] address, immediate, data_1, data_2;
  logic valid_1, valid_2;
  instr_name_e  instr_name;
  instr_type_e  instr_type;
  registers_t   regs;
  flag_vector_t flags;

  modport Combo(
      input address, immediate, data_1, data_2, valid_1, valid_2,
      input instr_name, instr_type, regs, flags
  );
  modport ReorderBuffer(input address, instr_type, regs, flags);
  modport Comparator(
      output address, immediate, data_1, data_2, valid_1, valid_2,
      output instr_name, instr_type, regs, flags
  );
endinterface
