module load_store_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_signals_if.rest gsi,
    instr_issue_if.combo issue[2],
    common_data_bus_if.combo cdb[2],
    cache_bus_if.comp data_bus
);

  station_unit_if load_store_feed ();

  logic [XLEN-1:0] load_store_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16)
  ) load_store_station (
      .gsi(gsi),
      .issue(issue),
      .cdb(cdb),
      .exec_feed(load_store_feed)
  );

  load_store #(
      .XLEN(XLEN)
  ) load_store (
      .exec_feed(load_store_fseed),
      .data_bus(data_bus),
      .result(load_store_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) load_store_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
