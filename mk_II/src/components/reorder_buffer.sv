module reorder_buffer #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_signals_if gsi,
    pc_interface_if pc,
    common_data_bus_if cdb[2],
    instr_issue_if issue[2]
);
  logic get_bus, bus_granted, bus_selected;

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) mult_div_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );
endmodule
