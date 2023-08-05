module mult_div_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_signals_if.rest gsi,
    instr_issue_if.combo issue[2],
    common_data_bus_if.combo cdb[2],
    output logic full
);

  station_unit_if mult_div_feed ();

  logic [XLEN-1:0] mult_div_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16)
  ) mult_div_station (
      .gsi(gsi),
      .issue(issue),
      .cdb(cdb),
      .exec_feed(mult_div_feed),
      .next(bus_granted),
      .full(full)
  );

  mult_div #(
      .XLEN(XLEN)
  ) mult_div (
      .exec_feed(mult_div_feed),
      .store_result(mult_div_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) mult_div_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
