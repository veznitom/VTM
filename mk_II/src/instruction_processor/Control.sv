// Copyright (c) 2024 veznitom

import pkg_defines::*;
`default_nettype none
module Control (
  input wire i_reset,
  input wire i_delete_tag,
  input wire i_clear_tag,

  input wire i_branch,
  input wire i_ren_empty,
  input wire i_full,       // if at least one thing is full halt

  output reg o_tag,
  output reg o_ld_halt,
  output reg o_dec_halt[2],
  output reg o_ren_halt,
  output reg o_res_halt,

  output reg o_clear
);
  logic tag, ld_dec_ren_halt, all_halt;

  assign o_ld_halt     = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_dec_halt[0] = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_dec_halt[1] = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_ren_halt    = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_res_halt    = all_halt | i_full;

  assign o_tag         = tag;
  assign o_clear       = i_delete_tag ? '1 : '0;

  always_comb begin
    if (i_reset || i_clear_tag || i_delete_tag) begin
      tag             = '0;
      ld_dec_ren_halt = '0;
      all_halt        = '0;
    end else begin
      if (tag) begin
        if (i_branch) begin
          tag             = '1;
          ld_dec_ren_halt = '1;
          all_halt        = '0;
        end else begin
          tag             = '1;
          ld_dec_ren_halt = '0;
          all_halt        = '0;
        end  // branch
      end else begin
        if (i_branch) begin
          tag             = '1;
          ld_dec_ren_halt = '1;
          all_halt        = '0;
        end else begin
          tag             = '0;
          ld_dec_ren_halt = '1;
          all_halt        = '0;
        end  // branch
        tag             = tag;
        ld_dec_ren_halt = '0;
        all_halt        = '0;
      end  // tag
    end  // else
  end
endmodule
