import structures::*;

interface instr_issue_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate, data_1, data_2;
  logic valid_1, valid_2;
  instr_name_e instr_name;
  st_type_e st_type;
  src_dest_t regs;
  flag_vector_t flags;
  modport proc(output address, immediate, regs, flags, st_type, instr_name);
  modport combo(input address, immediate, regs, flags, st_type, instr_name);
  modport rob(input address, regs, flags);
  modport cmp(inout address, immediate, regs, flags);
endinterface
