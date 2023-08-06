import structures::*;

interface issue_bus_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate, data_1, data_2;
  logic valid_1, valid_2;
  instr_name_e instr_name;
  st_type_e st_type;
  src_dest_t regs;
  flag_vector_t flags;

  modport combo(
      input address, immediate, data_1, data_2, valid_1, valid_2, instr_name, st_type, regs, flags
  );
  modport rob(input address, st_type, regs, flags);
  modport cmp(
      output address, immediate, data_1, data_2, valid_1, valid_2, instr_name, st_type, regs, flags
  );
endinterface
