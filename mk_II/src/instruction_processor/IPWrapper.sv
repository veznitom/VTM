// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module IPWrapper (
  IntfCSB cs,

  input  logic [31:0] i_cache_instr  [2],
  input  logic        i_cache_hit    [2],
  output logic [31:0] o_cache_address[2],
  output logic        o_cache_read   [2],

  //IntfInstrCache.Loader           cache          [2],
  IntfIssue.Comparator     issue  [2],
  IntfCDB.Comparator       data   [2],
  IntfRegQuery             query  [2],
  IntfRegValBus.Comparator reg_val[2],
  IntfFull.Issuer          full,

  input wire [31:0] i_jmp_address,
  input wire        i_jmp_write
);
  // ------------------------------- Wires -------------------------------
  wire [31:0] address[2], instr[2];
  wire loader_halt, decoder_halt[2], renamer_halt;
  wire status_no_ren, status_panic, status_full;

  IntfInstrInfo u_ld_dc[2] ();
  IntfInstrInfo u_dc_ren[2] ();
  IntfInstrInfo u_ren_res[2] ();
  IntfInstrInfo u_res_iss[2] ();
  IntfInstrInfo u_iss_cmb[2] ();

  // ------------------------------- Modules -------------------------------
  Loader u_loader (
    .cs             (cs),
    .i_cache_instr  (i_cache_instr),
    .i_cache_hit    (i_cache_hit),
    .o_cache_address(o_cache_address),
    .o_cache_read   (o_cache_read),
    .i_jmp_address  (i_jmp_address),
    .i_jmp_write    (i_jmp_write),
    .o_address      (address),
    .o_instr        (instr),
    .i_halt         (loader_halt)
  );

  Decoder u_decoder_1 (
    .cs        (cs),
    .instr_info(u_ld_dc[0]),
    .i_address (address[0]),
    .i_instr   (instr[0]),
    .i_halt    (decoder_halt[0])
  );

  Decoder u_decoder_2 (
    .cs        (cs),
    .instr_info(u_ld_dc[1]),
    .i_address (address[1]),
    .i_instr   (instr[1]),
    .i_halt    (decoder_halt[1])
  );

  Renamer u_renamer (
    .cs          (cs),
    .i_instr_info(u_dc_ren),
    .o_instr_info(u_ren_res),
    .query       (query),
    .i_halt      (renamer_halt),
    .o_no_ren    (status_no_ren)
  );

  Resolver u_resolver (
    .cs          (cs),
    .i_instr_info(u_ren_res),
    .o_instr_info(u_res_iss),
    .query       (query),
    .i_halt      (renamer_halt),
    .o_panic     (status_panic)
  );

  Issuer u_issuer (
    .cs          (cs),
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
    .o_ld_halt (loader_halt),
    .o_dec_halt(decoder_halt)
  );

  // ------------------------------- Behaviour -------------------------------
endmodule

