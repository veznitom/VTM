// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CDBArbiter #(
  parameter bit [7:0] ADDRESS = 8'h00
) (
  inout  wire [15:0] io_select,
  input  wire        i_get_bus,
  output wire        o_bus_granted,
  output wire        o_bus_index
);
  // ------------------------------- Wires -------------------------------
  logic [15:0] select;
  wire [1:0] over_ranked, selected;
  wire granted;

  // ------------------------------- Behaviour -------------------------------
  assign o_bus_granted = granted && i_get_bus;
  assign (weak1, strong0) io_select = select;
  assign o_bus_index = selected[1];

  assign granted = io_select[15:8] == ADDRESS || io_select[7:0] == ADDRESS;
  assign over_ranked = {io_select[15:8] < ADDRESS, io_select[7:0] < ADDRESS};
  assign selected = {io_select[15:8] == ADDRESS, io_select[7:0] == ADDRESS};

  always_comb begin : selection
    if (i_get_bus) begin
      if (granted) begin  // maintain granted
        if (selected[1]) select = {ADDRESS, io_select[7:0]};
        else select = {io_select[15:8], ADDRESS};
      end else begin  // try to get control
        if (over_ranked[1]) begin
          if (over_ranked[0]) select = 16'hffff;
          else select = {io_select[15:8], ADDRESS};
        end else select = {ADDRESS, io_select[7:0]};
      end
    end else select = 16'hffff;
  end

endmodule
