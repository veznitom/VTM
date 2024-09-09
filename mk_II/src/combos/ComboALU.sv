// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboALU #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00
) (
  IntfCSB.tag     cs,
  IntfIssue.Combo issue[2],
  IntfCDB.Combo   data [2],

  output wire o_full
);
  // ------------------------------- Wires -------------------------------
  IntfExtFeed u_alu_feed ();

  wire [31:0] alu_result;
  wire        get_bus;
  wire        bus_granted;
  wire        bus_selected;

  // ------------------------------- Modules -------------------------------
  ReservationStation #(
    .SIZE      (16),
    .INSTR_TYPE(AL)
  ) u_station (
    .cs    (cs),
    .issue (issue),
    .data  (data),
    .feed  (u_alu_feed),
    .i_next(bus_granted),
    .o_rrn (),
    .o_full(o_full)
  );

  ALU u_alu (
    .i_data_1    (u_alu_feed.data_1),
    .i_data_2    (u_alu_feed.data_2),
    .i_address   (u_alu_feed.address),
    .i_immediate (u_alu_feed.immediate),
    .i_instr_name(u_alu_feed.instr_name),
    .o_result    (u_alu_feed.result)
  );

  CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .io_select     (),
    .i_get_bus     (),
    .o_bus_granted (),
    .o_bus_selected()
  );

  // ------------------------------- Behaviour -------------------------------
  //assign get_bus = u_alu_feed.instr_name != UNKNOWN;
endmodule
