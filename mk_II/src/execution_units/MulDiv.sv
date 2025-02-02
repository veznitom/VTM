// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module MulDiv (
  IntfExtFeed.MulDiv feed
);
  // ------------------------------- Wires -------------------------------
  reg [31:0] upper_u, upper_s, upper_su;
  reg [31:0] lower_u, lower_s, lower_su;
  reg [31:0] divident_u, divident_s;
  reg [31:0] remainder_u, remainder_s;
  // ------------------------------- Behaviour -------------------------------

  always_comb begin
    {upper_u, lower_u}   = feed.data_1 * feed.data_2;
    {upper_s, lower_s}   = $signed(feed.data_1) * $signed(feed.data_2);
    {upper_su, lower_su} = $signed(feed.data_1) * feed.data_2;
    divident_u           = feed.data_1 / feed.data_2;
    divident_s           = $signed(feed.data_1) / $signed(feed.data_2);
    remainder_u          = feed.data_1 % feed.data_2;
    remainder_s          = $signed(feed.data_1) % $signed(feed.data_2);
  end

  always_comb begin
    case (feed.instr_name)
      MUL:     feed.result = lower_s;
      MULH:    feed.result = upper_s;
      MULHSU:  feed.result = upper_su;
      MULHU:   feed.result = upper_u;
      DIV:     feed.result = divident_s;
      DIVU:    feed.result = divident_u;
      REM:     feed.result = remainder_s;
      REMU:    feed.result = remainder_u;
      default: feed.result = 'z;
    endcase
  end

endmodule
