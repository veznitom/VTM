import structures::*;

interface instr_issue_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate;
  logic [5:0] src_1, src_2, arn, rrn;
  flag_vector_t flags;
  instr_name_e instr_name;
  st_type_e st_type;
  modport proc(output address, immediate, src_1, src_2, arn, rrn, flags, st_type, instr_name);
  modport combo(input address, immediate, src_1, src_2, arn, rrn, flags, st_type, instr_name);
  modport rob(input address, arn, rrn, flags);
  modport cmp(inout address, immediate, src_1, src_2, arn, rrn, flags);
endinterface
