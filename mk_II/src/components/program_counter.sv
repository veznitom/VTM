import global_variables::XLEN;

module program_counter (
    global_bus_if.rest global_bus,
    pc_bus_if.pc pc_bus
);
  // ------------------------------- Behaviour -------------------------------
  always_comb begin : control
    if (global_bus.reset) pc_bus.address = {XLEN{1'h0}};

    if (pc_bus.write) pc_bus.address = pc_bus.jmp_address;
    else if (pc_bus.plus_8) pc_bus.address = pc_bus.address + 8;
    else if (pc_bus.plus_4) pc_bus.address = pc_bus.address + 4;
  end
endmodule
