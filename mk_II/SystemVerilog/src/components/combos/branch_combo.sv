import global_variables::XLEN;

module branch_combo #(
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_bus_if.rest global_bus,
    issue_bus_if.combo issue_bus[2],
    common_data_bus_if.combo data_bus[2],

    output logic full
);
  // ------------------------------- Wires -------------------------------
  feed_bus_if branch_feed ();

  logic [XLEN-1:0] store_result, jump_result;
  logic get_bus;
  logic bus_granted;
  logic bus_selected;

  // ------------------------------- Modules -------------------------------
  reservation_station #(
      .SIZE(16),
      .INSTR_TYPE(BR)
  ) branch_station (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .feed_bus(branch_feed),
      .next(bus_granted),
      .full(full)
  );

  branch branch (
      .feed_bus(branch_feed),
      .store_result(store_result),
      .jump_result(jump_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) branch_arbiter (
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
