// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module MulDiv (
  input wire              [31:0] i_data_1,
  input wire              [31:0] i_data_2,
  input wire instr_name_e        i_instr_name,

  output reg [31:0] o_result
);
  // ------------------------------- Wires -------------------------------
  reg [31:0] upper_u, upper_s, upper_su;
  reg [31:0] lower_u, lower_s, lower_su;
  reg [31:0] divident_u, divident_s;
  reg [31:0] remainder_u, remainder_s;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    {upper_u, lower_u}   = i_data_1 * i_data_2;
    {upper_s, lower_s}   = $signed(i_data_1) * $signed(i_data_2);
    {upper_su, lower_su} = $signed(i_data_1) * i_data_2;
    divident_u           = i_data_1 / i_data_2;
    divident_s           = $signed(i_data_1) / $signed(i_data_2);
    remainder_u          = i_data_1 % i_data_2;
    remainder_s          = $signed(i_data_1) % $signed(i_data_2);
  end

  always_comb begin
    case (i_instr_name)
      MUL:     o_result = lower_s;
      MULH:    o_result = upper_s;
      MULHSU:  o_result = upper_su;
      MULHU:   o_result = upper_u;
      DIV:     o_result = divident_s;
      DIVU:    o_result = divident_u;
      REM:     o_result = remainder_s;
      REMU:    o_result = remainder_u;
      default: o_result = 'z;
    endcase
  end
endmodule
