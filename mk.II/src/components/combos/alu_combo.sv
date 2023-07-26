module alu_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_signals_if gsi,
    instr_issue_if issue[2],
    common_data_bus_if cdb[2]
);

  station_unit_if alu_feed ();

  logic [XLEN-1:0] alu_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16)
  ) alu_station (
      .gsi(gsi),
      .issue(issue),
      .cdb(cdb),
      .exec_feed(alu_feed)
  );

  alu #(
      .XLEN(XLEN)
  ) alu (
      .exec_feed(alu_feed),
      .result(alu_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) alu_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
