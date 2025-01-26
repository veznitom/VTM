// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboMulDiv #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00,
  parameter int       SIZE_BITS       = 3
) (
  IntfCSB.tag     cs,
  IntfIssue.Combo issue[2],
  IntfCDB.Combo   data [2],

  output wire o_full
);
  // ------------------------------- Wires -------------------------------
  IntfExtFeed u_mult_div_feed ();

  wire [31:0] mult_div_result;
  wire [15:0] select;
  wire        get_bus;
  wire        bus_granted;
  wire        bus_index;

  // ------------------------------- Modules -------------------------------
  ReservationStation #(
    .SIZE_BITS (SIZE_BITS),
    .INSTR_TYPE(MD)
  ) u_station (
    .cs    (cs),
    .issue (issue),
    .data  (data),
    .feed  (u_mult_div_feed),
    .i_next(bus_granted),
    .o_rrn (),
    .o_full(o_full)
  );

  MulDiv u_mul_div (
    .i_data_1    (u_mult_div_feed.data_1),
    .i_data_2    (u_mult_div_feed.data_2),
    .i_instr_name(u_mult_div_feed.instr_name),
    .o_result    (u_mult_div_feed.result)
  );

  CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .io_select    (select),
    .i_get_bus    (get_bus),
    .o_bus_granted(bus_granted),
    .o_bus_index  (bus_index)
  );
  // ------------------------------- Behaviour -------------------------------
  assign select = {data[1].select, data[0].select};

endmodule
