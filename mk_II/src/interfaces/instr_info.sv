interface instr_info_bus_if;


  modport in(input address, immediate, instr_name, regs, instr_type, flags, import clear);
  modport out(output address, immediate, instr_name, regs, instr_type, flags, import clear);

  task automatic clear();
    address <= {XLEN{1'h0}};
    immediate <= {XLEN{1'h0}};
    instr_name <= UNKNOWN;
    instr_type <= XX;
    regs <= '{6'h00, 6'h00, 6'h00, 6'h00};
    flags <= '{1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface
