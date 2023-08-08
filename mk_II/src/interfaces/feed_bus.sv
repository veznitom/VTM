import structures::*;

interface feed_bus_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] data_1, data_2, address, immediate;
  logic [7:0] instr_name;
  logic [5:0] rrn;

  modport station(output data_1, data_2, address, immediate, rrn, instr_name);
  modport exec(input data_1, data_2, address, immediate, rrn, instr_name);
endinterface
