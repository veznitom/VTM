module branch_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_signals_if.rest gsi,
    instr_issue_if.combo issue[2],
    common_data_bus_if.combo cdb[2],
    output logic full
);

  station_unit_if branch_feed ();

  logic [XLEN-1:0] store_result, jump_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16)
  ) branch_station (
      .gsi(gsi),
      .issue(issue),
      .cdb(cdb),
      .exec_feed(branch_feed),
      .next(bus_granted),
      .full(full)
  );

  branch #(
      .XLEN(XLEN)
  ) branch (
      .exec_feed(branch_feed),
      .store_result(store_result),
      .jump_result(jump_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) branch_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
