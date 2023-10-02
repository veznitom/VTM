// Edit arbiter so bus avaiability is check here instead in the combo
// Arbiter will provide which bus to use
// Common data bus adressing is done with 4 bits (15 device addresses, 0 is disconnected)
// therefore select has 'select' size of multiple 4 of the number of commond data busses
// => bus_select selects which common data bus is to be selected

module arbiter #(
    parameter logic [7:0] ADDRESS = 8'h00
) (
    input logic [15:0] select,
    input logic get_bus,
    output logic bus_granted,
    output logic bus_selected
);
  assign bus_granted = get_bus;
endmodule
