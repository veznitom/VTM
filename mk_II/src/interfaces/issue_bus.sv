import structures::*;

interface issue_bus_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate, data_1, data_2;
  logic valid_1, valid_2;
  instr_name_e  instr_name;
  registers_t   regs;
  instr_type_e  instr_type;
  flag_vector_t flags;

  modport combo(
      input address, immediate, data_1, data_2, valid_1, valid_2,
      instr_name, instr_type, regs, flags
  );
  modport rob(input address, instr_type, regs, flags);
  modport cmp(
      output address, immediate, data_1, data_2, valid_1, valid_2,
      instr_name, instr_type, regs, flags
  );

  task automatic clear();
    address = {XLEN{1'h0}};
    immediate = {XLEN{1'h0}};
    data_1 = {XLEN{1'h0}};
    data_2 = {XLEN{1'h0}};
    {valid_1, valid_2} = {1'h0, 1'h0};
    instr_name = UNKNOWN;
    instr_type = XX;
    regs = '{6'h00, 6'h00, 6'h00, 6'h00};
    flags = {1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface
