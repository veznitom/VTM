// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface ifc_issue;
  logic [31:0] address, immediate, data_1, data_2;
  logic valid_1, valid_2;
  instr_name_e  instr_name;
  instr_type_e  instr_type;
  registers_t   regs;
  flag_vector_t flags;

  modport combo(
      input address, immediate, data_1, data_2, valid_1, valid_2,
      input instr_name, instr_type, regs, flags
  );
  modport rob(input address, instr_type, regs, flags);
  modport cmp(
      output address, immediate, data_1, data_2, valid_1, valid_2,
      output instr_name, instr_type, regs, flags,
      import clear
  );

  task automatic clear();
    address            <= '0;
    immediate          <= '0;
    data_1             <= '0;
    data_2             <= '0;
    {valid_1, valid_2} <= {1'h0, 1'h0};
    instr_name         <= UNKNOWN;
    instr_type         <= XX;
    regs               <= '{6'h00, 6'h00, 6'h00, 6'h00};
    flags              <= {1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface
