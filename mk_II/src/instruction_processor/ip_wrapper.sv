import pkg_defines::*;

`include "ip_comparator.sv"
`include "ip_control.sv"
`include "ip_decoder.sv"
`include "ip_issuer.sv"
`include "ip_loader.sv"
`include "ip_resolver.sv"

module ip_wrapper (
    input clock,
    input reset
);
  // ------------------------------- Wires -------------------------------

  // ------------------------------- Modules -------------------------------
  ip_loader loader ();

  ip_decoder decoder_0 ();

  ip_decoder decoder_1 ();

  ip_renamer renamer ();

  ip_resolver resolver ();

  ip_issuer issuer ();

  ip_comparator comparator_0 ();

  ip_comparator comparator_1 ();

  // ------------------------------- Behaviour -------------------------------

endmodule

