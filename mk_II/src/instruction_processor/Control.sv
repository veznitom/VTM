// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Control (
  output wire o_ld_halt,
  output wire o_dec_halt[2]
);
  assign o_ld_halt     = '0;
  assign o_dec_halt[0] = '0;
  assign o_dec_halt[1] = '0;
endmodule
