module combo_alu #(
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00
) (
    input clock,
    input reset,
    input delete_tag,
    input clear_tag,

    issue_bus_if.combo issue_bus[2],
    common_data_bus_if.combo data_bus[2],

    output logic full
);
  // ------------------------------- Wires -------------------------------
  feed_bus_if alu_feed ();

  logic [31:0] alu_result;
  logic get_bus;
  logic bus_granted;
  logic bus_selected;

  // ------------------------------- Modules -------------------------------
  reservation_station #(
      .SIZE(16),
      .INSTR_TYPE(AL)
  ) alu_station (
      .global_bus(global_bus),
      .issue_bus(issue_bus),
      .data_bus(data_bus),
      .feed_bus(alu_feed),
      .next(bus_granted),
      .full(full)
  );

  alu alu (
      .feed_bus(alu_feed),
      .result  (alu_result)
  );

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) alu_arbiter (
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

  // ------------------------------- Behaviour -------------------------------
  assign get_bus = alu_feed.instr_name != UNKNOWN;
endmodule
