module arbiter #(
    parameter logic [7:0] ADDRESS = 8'h00
) (
    input logic [15:0] select,
    input logic get_bus,
    output logic bus_granted,
    output logic bus_selected
);
  // ------------------------------- Behaviour -------------------------------
  assign bus_granted = get_bus;
endmodule
