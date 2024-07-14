module combo_load_store #(
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    input clock,
    input reset,
    input delete_tag,
    input clear_tag,

    issue_bus_if.combo issue_bus[2],
    common_data_bus_if.combo data_bus[2],

    input cache_hit,
    inout wire [31:0] cache_data,
    output logic [31:0] cache_address,
    output logic cache_read,
    output logic cache_write,

    output logic full
);
  // ------------------------------- Wires -------------------------------
  feed_bus_if load_store_feed ();

  logic [31:0] load_store_result;
  logic get_bus;
  logic bus_granted;
  logic bus_selected;
  // ------------------------------- Modules -------------------------------
  reservation_station #(
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

  load_store load_store (
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
