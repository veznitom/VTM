// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module IPWrapper (
  input wire i_clock,
  input wire i_reset,
  input wire i_clear_tag,
  input wire i_delete_tag,

  // Loader
  input  wire [31:0] i_cache_instr  [2],
  input  wire        i_cache_hit    [2],
  input  wire [31:0] i_jmp_address,
  input  wire        i_jmp_write,
  output wire [31:0] o_cache_address[2],
  output wire        o_cache_read   [2],

  // Renamer & Resolver
  input wire [1:0] i_ren_capacity,

  IntfRegQuery.IPWrapper query,

  // Issuer
  IntfFull.Issuer full,

  // Comparators
  IntfIssue.Comparator     issue  [2],
  IntfCDB.Comparator       data   [2],
  IntfRegValBus.Comparator reg_val[2]
);
  // ------------------------------- Wires -------------------------------
  wire [31:0] address[2], instr[2];
  wire loader_halt, decoder_halt[2], renamer_halt, resolver_halt;
  wire status_ren_empty, status_panic, status_full, status_branch;
  wire tag, clear;

  IntfInstrInfo u_dc_ren[2] ();
  IntfInstrInfo u_ren_res[2] ();
  IntfInstrInfo u_res_iss[2] ();
  IntfInstrInfo u_iss_cmb[2] ();

  // ------------------------------- Modules -------------------------------
  Loader u_loader (
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_cache_instr  (i_cache_instr),
    .i_cache_hit    (i_cache_hit),
    .o_cache_address(o_cache_address),
    .o_cache_read   (o_cache_read),
    .i_jmp_address  (i_jmp_address),
    .i_jmp_write    (i_jmp_write),
    .o_address      (address),
    .o_instr        (instr),
    .i_halt         (loader_halt),
    .i_clear        (clear)
  );

  Decoder u_decoder_1 (
    .i_clock   (i_clock),
    .i_reset   (i_reset),
    .instr_info(u_dc_ren[0]),
    .i_address (address[0]),
    .i_instr   (instr[0]),
    .i_halt    (decoder_halt[0])
  );

  Decoder u_decoder_2 (
    .i_clock   (i_clock),
    .i_reset   (i_reset),
    .instr_info(u_dc_ren[1]),
    .i_address (address[1]),
    .i_instr   (instr[1]),
    .i_halt    (decoder_halt[1])
  );

  Renamer u_renamer (
    .i_clock(i_clock),
    .i_reset(i_reset),

    .i_instr_info(u_dc_ren),
    .o_instr_info(u_ren_res),

    .i_query_ren_capacity(i_ren_capacity),
    .o_query_input_regs  (query.input_regs),
    .o_query_rename      (query.rename),
    .o_query_tag         (query.tag),

    .i_halt     (renamer_halt),
    .i_tag      (tag),
    .o_branch   (status_branch),
    .o_ren_empty(status_ren_empty)
  );

  Resolver u_resolver (
    .i_clock(i_clock),
    .i_reset(i_reset),

    .i_instr_info(u_ren_res),
    .o_instr_info(u_res_iss),

    .i_query_output_regs(query.output_regs),

    .i_halt (renamer_halt),
    .i_tag  (tag),
    .o_panic(status_panic)
  );

  Issuer u_issuer (
    .i_clock     (i_clock),
    .i_reset     (i_reset),
    .i_instr_info(u_res_iss),
    .o_instr_info(u_iss_cmb),
    .i_halt      (renamer_halt),
    .full        (full),
    .o_full      (status_full)
  );

  Comparator u_comparator_1 (
    .instr_info(u_iss_cmb[0]),
    .issue     (issue[0]),
    .reg_val   (reg_val[0]),
    .data      (data)
  );

  Comparator u_comparator_2 (
    .instr_info(u_iss_cmb[1]),
    .issue     (issue[1]),
    .reg_val   (reg_val[1]),
    .data      (data)
  );

  Control u_control (
    .i_reset     (i_reset),
    .i_clear_tag (i_clear_tag),
    .i_delete_tag(i_delete_tag),

    .i_branch(status_branch),
    .i_full  (status_full),

    .o_tag(tag),

    .o_ld_halt (loader_halt),
    .o_dec_halt(decoder_halt),
    .o_ren_halt(renamer_halt),
    .o_res_halt(resolver_halt),

    .o_clear(clear)
  );

  // ------------------------------- Behaviour -------------------------------

endmodule

