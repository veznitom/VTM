// Copyright (c) 2024 veznitom

import pkg_defines::*;
`default_nettype none
module Control (
  IntfCSB.tag cs,

  input logic i_branch,
  input logic i_ren_empty,
  input logic i_full,       // if at least one thing is full halt

  output logic o_tag_ren,
  output logic o_tag_res,
  output logic o_ld_halt,
  output logic o_dec_halt[2],
  output logic o_ren_halt,
  output logic o_res_halt,

  output logic o_clear
);
  logic [2:0] tag_mem;
  logic tag, ld_dec_ren_halt, all_halt;

  assign o_ld_halt     = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_dec_halt[0] = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_dec_halt[1] = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_ren_halt    = all_halt | i_full | ld_dec_ren_halt | i_ren_empty;
  assign o_res_halt    = all_halt | i_full;

  assign o_tag_ren     = tag;
  assign o_tag_res     = tag_mem[2];
  assign o_clear       = cs.delete_tag ? '1 : '0;

  always_ff @(posedge cs.clock) begin
    if (cs.reset || cs.clear_tag || cs.delete_tag) tag_mem <= '0;
    else tag_mem <= {tag_mem[1:0], tag};
  end

  always_comb begin
    if (cs.reset || cs.clear_tag || cs.delete_tag) begin
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
