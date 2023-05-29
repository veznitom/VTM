module Arbiter #(
    parameter address = 4'b0000
)(
    input logic get_bus,
    inout wire [3:0] select,
    output logic bus_granted
);

  wire status;
  assign status = get_bus;
  assign (weak1 , strong0 ) select[3] = ~(address[3] & status);
  assign (weak1 , strong0 ) select[2] = ~(address[2] & status & (address[3] | select[3]));
  assign (weak1 , strong0 ) select[1] = ~(address[1] & status & (address[3] | select[3]) & (address[2] | select[2]));
  assign (weak1 , strong0 ) select[0] = ~(address[0] & status & (address[3] | select[3]) & (address[2] | select[2]) & (address[1] | select[1]));
  assign bus_granted = status & (address[0] | select[0]) & (address[1] | select[1]) & (address[2] | select[2]) & (address[3] | select[3]);
endmodule