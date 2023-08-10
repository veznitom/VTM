import structures::*;

module load_store_combo #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    global_bus_if.rest global_bus,
    issue_bus_if.combo issue_bus[2],
    data_cache_bus_if.load_store cache_bus,
    common_data_bus_if.combo data_bus[2],

    output logic full
);

  feed_bus_if #(.XLEN(XLEN)) load_store_feed ();

  logic [XLEN-1:0] load_store_result;
  logic get_bus, bus_granted, bus_selected;


  reservation_station #(
      .XLEN(XLEN),
      .SIZE(16),
      .INSTR_TYPE(LS)
  ) load_store_station (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .feed_bus(load_store_feed),
      .next(bus_granted),
      .full(full)
  );

  load_store #(
      .XLEN(XLEN)
  ) load_store (
      .feed_bus(load_store_feed),
      .cache_bus(cache_bus),
      .result(load_store_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) load_store_arbiter (
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

endmodule
