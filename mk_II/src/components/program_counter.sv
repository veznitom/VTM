module program_counter #(
    parameter int XLEN = 32
) (
    global_signals.rest gsi,
    pc_interface_if.pc  inter
);
  logic [XLEN-1:0] address;

  assign inter.address = address;

  always_comb begin : control
    if (gsi.reset) address = {XLEN{1'h0}};
    else begin
      if (inter.write) address = inter.jmp_address;
      else if (inter.plus_8) address = address + 8;
      else if (inter.plus_4) address = address + 4;
      else address = address;
    end
  end
endmodule
