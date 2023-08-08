import structures::*;

module program_counter #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    pc_bus_if.pc pc_bus
);
  logic [XLEN-1:0] address;

  assign pc_bus.address = address;

  always_comb begin : control
    if (global_bus.reset) address = {XLEN{1'h0}};
    else begin
      if (pc_bus.write) address = pc_bus.jmp_address;
      else if (pc_bus.plus_8) address = address + 8;
      else if (pc_bus.plus_4) address = address + 4;
      else address = address;
    end
  end
endmodule
