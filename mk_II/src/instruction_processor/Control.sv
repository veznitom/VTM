// Copyright (c) 2024 veznitom

import pkg_defines::*;
`default_nettype none
module Control (
  input wire i_reset,
  input wire i_delete_tag,
  input wire i_clear_tag,

  input wire i_branch,
  input wire i_full,

  output reg o_tag,

  output reg o_ld_halt,
  output reg o_dec_halt[2],
  output reg o_ren_halt,
  output reg o_res_halt,

  output reg o_clear
);
  logic tag, ld_dec_ren;

  assign o_ld_halt     = '0;  //| i_full | ld_dec_ren;
  assign o_dec_halt[0] = '0;  //| i_full | ld_dec_ren;
  assign o_dec_halt[1] = '0;  //| i_full | ld_dec_ren;
  assign o_ren_halt    = '0;  //| i_full;
  assign o_res_halt    = '0;  //| i_full;

  always_comb begin
    if (i_reset || i_clear_tag) begin
      tag        = '0;
      o_clear    = '0;
      ld_dec_ren = '0;
    end else if (i_delete_tag) begin
      tag        = '0;
      o_clear    = '1;
      ld_dec_ren = '0;
    end else begin
      o_clear = '0;
      if (tag) begin
        if (i_branch) begin
          ld_dec_ren = '1;
        end else begin
          tag        = tag;
          ld_dec_ren = '0;
        end
      end else begin
        if (i_branch) begin
          tag = '1;
        end else begin
          tag = '0;
        end
        ld_dec_ren = '0;
      end
    end
  end
endmodule
