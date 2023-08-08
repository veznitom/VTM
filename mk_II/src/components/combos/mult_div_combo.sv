module mult_div_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_bus_if.rest global_bus,
    issue_bus_if.combo issue[2],
    common_data_bus_if.combo data_bus[2],

    output logic full
);

  feed_bus_if #(.XLEN(XLEN)) mult_div_feed ();

  logic [XLEN-1:0] mult_div_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16),
      .INSTR_TYPE(MD)
  ) mult_div_station (
      .global_bus(global_bus),
      .issue(issue),
      .data_bus(data_bus),
      .feed_bus(mult_div_feed),
      .next(bus_granted),
      .full(full)
  );

  mult_div #(
      .XLEN(XLEN)
  ) mult_div (
      .feed_bus(mult_div_feed),
      .result  (mult_div_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) mult_div_arbiter (
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
