// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CDBArbiter #(
  parameter bit [7:0] ADDRESS = 8'h00
) (
  inout  wire [15:0] io_select,
  input  wire        i_get_bus,
  output wire        o_bus_granted,
  output wire        o_bus_selected
);
  // ------------------------------- Behaviour -------------------------------
  assign o_bus_granted = i_get_bus;
endmodule
