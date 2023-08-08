interface instr_info_bus_if #(
    parameter int XLEN = 32
);
  logic [XLEN-1:0] address, immediate;
  instr_name_e  instr_name;
  registers_t   regs;
  instr_type_e  instr_type;
  flag_vector_t flags;

  modport in(input address, immediate, instr_name, regs, instr_type, flags, import clear);
  modport out(output address, immediate, instr_name, regs, instr_type, flags, import clear);

  task automatic clear();
    address = {XLEN{1'h0}};
    immediate = {XLEN{1'h0}};
    instr_name = UNKNOWN;
    instr_type = XX;
    regs = '{6'h00, 6'h00, 6'h00, 6'h00};
    flags = '{1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface
