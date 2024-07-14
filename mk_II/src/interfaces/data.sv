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
          instr_name, instr_type, regs, flags
  );
  modport rob(input address, instr_type, regs, flags);
  modport cmp(
      output address, immediate, data_1, data_2, valid_1, valid_2,
      instr_name, instr_type, regs, flags,
      import clear
  );

  task automatic clear();
    address <= '0;
    immediate <= '0;
    data_1 <= '0;
    data_2 <= '0;
    {valid_1, valid_2} <= {1'h0, 1'h0};
    instr_name <= UNKNOWN;
    instr_type <= XX;
    regs <= '{6'h00, 6'h00, 6'h00, 6'h00};
    flags <= {1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface

interface ifc_common_data_bus;
  wire [31:0] result, address, jmp_address;
  wire [5:0] arn, rrn;
  wire [3:0] select;
  logic reg_write, cache_write;

  modport combo(
    input arn, inout result, address, jmp_address, select,
    output rrn, reg_write);
  modport rob(
    inout result, address, jmp_address, arn, rrn, select,
    output reg_write, cache_write);
  modport reg_file(input result, address, arn, rrn, reg_write);
  modport cache(input result, address, cache_write);
  modport cmp(input result, arn, rrn);
endinterface