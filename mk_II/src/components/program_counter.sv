import global_variables::XLEN;

module program_counter (
    global_bus_if.rest global_bus,
    pc_bus_if.pc pc_bus
);
  // ------------------------------- Behaviour -------------------------------
  logic [XLEN-1:0] address;
  // ------------------------------- Behaviour -------------------------------
  assign pc_bus.address = address;

  always_comb begin
    if (global_bus.reset) address = {XLEN{1'h0}};
  end

  always_ff @(posedge global_bus.clock) begin
    if (pc_bus.write) address <= pc_bus.jmp_address;
    else if (pc_bus.plus_8) address <= pc_bus.address + 8;
    else if (pc_bus.plus_4) address <= pc_bus.address + 4;
  end
endmodule
