import structures::*;

interface station_unit_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] data_1, data_2, address, immediate;
  logic [5:0] rrn;
  instr_name_e instr_name;
  modport station(output data_1, data_2, address, immediate, rrn, instr_name, import clear);
  modport exec(input data_1, data_2, address, immediate, rrn, instr_name);
endinterface
