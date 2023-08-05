/*  Instruction processer combines loader, decoder, resolver, and issuer into one block to ease the cpu module complexity
*/

module instr_processer #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    // Loaders
    input logic [XLEN-1:0] address[2],
    input logic [31:0] instr[2],
    input logic [1:0] hit,
    // Resolvers
    register_query_if query[2],
    // Issuesrs
    instr_issue_if issue[2],
    fullness_indication_if fullness,
    // Comparator
    instr_issue_if issue,
    register_values_if reg_val,
    common_data_bus_if cdb[2]
);
  logic stop;

  logic [XLEN-1:0] load_address_out[2];
  logic [31:0] load_instrs_out[2];

  instr_info_if dec_to_res[2] (), res_to_issue[2] (), issue_to_cmp[2] ();

  loader #(
      .XLEN(XLEN)
  ) loader (
      .gsi(gsi),
      .address_in(address),
      .instrs_in(instrs),
      .hit(hit),
      .stop(stop),
      .address_out(load_address_out),
      .instrs_out(load_instrs_out)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_0 (
      .gsi(gsi),
      .instr_info(dec_to_res[0]),
      .address(load_address_out[0]),
      .instr(load_instrs_out[0]),
      .stop(stop)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_1 (
      .gsi(gsi),
      .instr_info(dec_to_res[1]),
      .address(load_address_out[1]),
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
      .instr_info_in(res_to_issue),
      .instr_info_out(issue_to_cmp),
      .fullness(fullness),
      .stop(stop)
  );

  comparator comparator_1 (
      .instr_info(issue_to_cmp[0]),
      .issue_in(issue[0]),
      .reg_val(reg_val[0]),
      .cdb(cdb)
  );

  comparator comparator_2 (
      .instr_info(issue_to_cmp[1]),
      .issue_in(issue[1]),
      .reg_val(reg_val[1]),
      .cdb(cdb)
  );
endmodule

