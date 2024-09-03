// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboBranch #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00
) (
  IntfCSB.tag     cs,
  IntfIssue.combo issue[2],
  IntfCDB.combo   data [2],

  output wire o_full
);
  // ------------------------------- Wires -------------------------------
  IntfExtFeed u_branch_feed ();

  wire [31:0] store_result, jump_result;
  wire get_bus;
  wire bus_granted;
  wire bus_selected;

  // ------------------------------- Modules -------------------------------
  ReservationStation #(
    .SIZE      (16),
    .INSTR_TYPE(BR)
  ) u_station (
    .cs    (cs),
    .issue (issue),
    .data  (data),
    .feed  (u_branch_feed),
    .i_next(bus_granted),
    .o_rrn (),
    .o_full(o_full)
  );

  Branch u_branch (
    .i_data_1      (u_branch_feed.data_1),
    .i_data_2      (u_branch_feed.data_2),
    .i_address     (u_branch_feed.address),
    .i_immediate   (u_branch_feed.immediate),
    .i_instr_name  (u_branch_feed.instr_name),
    .o_store_result(u_branch_feed.result),
    .o_jump_result (u_branch_feed.jump_result)
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
