import global_variables::XLEN;
import structures::instr_name_e;

interface feed_bus_if;
  logic [XLEN-1:0] data_1, data_2, address, immediate;
  instr_name_e instr_name;
  logic [5:0] rrn;

  modport station(output data_1, data_2, address, immediate, rrn, instr_name);
  modport exec(input data_1, data_2, address, immediate, rrn, instr_name);
endinterface
