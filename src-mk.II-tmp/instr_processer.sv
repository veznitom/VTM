/*  Instruction processer combines loader, decoder, resolver, and issuer into one block to ease the cpu module complexity
*/

module instr_processer #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    // Loaders
    input logic [XLEN-1:0] addresses[2],
    input logic [31:0] instrs[2],
    input logic [1:0] hit,
    // Resolvers
    register_query_if query[2],
    // Issuesrs
    instr_issue_if issue[2],
    input logic [2:0] st_fullness
);
  logic stop;

  logic [XLEN-1:0] load_addresses_out[2];
  logic [31:0] load_instrs_out[2];

  instr_info_if dec_to_res[2] (), res_to_issue[2] ();

  loader #(
      .XLEN(XLEN)
  ) loader (
      .gsi(gsi),
      .addresses_in(addresses),
      .instrs_in(instrs),
      .hit(hit),
      .stop(stop),
      .addresses_out(load_addresses_out),
      .instrs_out(load_instrs_out)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_0 (
      .gsi(gsi),
      .instr_info(dec_to_res[0]),
      .address_in(load_addresses_out[0]),
      .instr(load_instrs_out[0]),
      .stop(stop)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_1 (
      .gsi(gsi),
      .instr_info(dec_to_res[1]),
      .address_in(load_addresses_out[1]),
      .instr(load_instrs_out[1]),
      .stop(stop)
  );

  resolver #(
      .XLEN(XLEN)
  ) resolver (
      .gsi(gsi),
      .query(query),
      .instr_info_in(dec_to_res),
      .instr_info_out(res_to_issue),
      .stop(stop)
  );

  issuer #(
      .XLEN(XLEN)
  ) issuer (
      .gsi(gsi),
      .issue(issue),
      .instr_info_if(res_to_issue),
      .st_fullness(st_fullness),
      .stop(stop)
  );
endmodule

