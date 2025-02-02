// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
interface IntfExtFeed;
  logic        [31:0] data_1;
  logic        [31:0] data_2;
  logic        [31:0] address;
  logic        [31:0] immediate;
  instr_name_e        instr_name;
  logic        [31:0] result;
  logic        [31:0] result_address;
  logic done, tag;

  modport Station(output data_1, data_2, address, immediate, instr_name, tag);

  modport ALU(
      input data_1, data_2, address, immediate, instr_name,
      output result
  );

  modport Branch(
      input data_1, data_2, address, immediate, instr_name,
      output result, result_address
  );

  modport LoadStore(
      input data_1, data_2, address, immediate, instr_name, tag,
      output result, result_address, done
  );

  modport MulDiv(
      input data_1, data_2, instr_name,
      output result
  );
endinterface
