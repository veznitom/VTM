// Edit arbiter so bus avaiability is check here instead in the combo
// Arbiter will provide which bus to use

module arbiter #(
    parameter logic [7:0] ADDRESS = 8'h00
) (
    input logic [7:0] select,
    input logic get_bus,
    output logic bus_granted,
    output logic bus_select
);
    TODO();
endmodule
