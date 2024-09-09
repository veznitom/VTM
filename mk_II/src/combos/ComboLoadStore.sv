// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboLoadStore #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00
) (
  IntfCSB.tag             cs,
  IntfIssue.Combo         issue[2],
  IntfCDB.Combo           data [2],
  IntfDataCache.LoadStore cache,

  output wire o_full
);
  // ------------------------------- Wires -------------------------------
  IntfExtFeed u_load_store_feed ();

  wire [31:0] load_store_result;
  wire        get_bus;
  wire        bus_granted;
  wire        bus_selected;
  // ------------------------------- Modules -------------------------------
  ReservationStation #(
    .SIZE      (16),
    .INSTR_TYPE(LS)
  ) u_station (
    .cs    (cs),
    .issue (issue),
    .data  (data),
    .feed  (u_load_store_feed),
    .i_next(bus_granted),
    .o_rrn (),
    .o_full(o_full)
  );

  LoadStore u_load_store (
    .i_data_1       (u_load_store_feed.data_1),
    .i_data_2       (u_load_store_feed.data_2),
    .i_address      (u_load_store_feed.address),
    .i_immediate    (u_load_store_feed.immediate),
    .i_instr_name   (u_load_store_feed.instr_name),
    .i_cache_hit    (cache.hit),
    .io_cache_data  (cache.data),
    .o_cache_address(cache.address),
    .o_cache_read   (cache.read),
    .o_cache_write  (cache.write),
    .o_result       (u_load_store_feed.result)
  );

  CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .io_select     (),
    .i_get_bus     (),
    .o_bus_granted (),
    .o_bus_selected()
  );
endmodule
