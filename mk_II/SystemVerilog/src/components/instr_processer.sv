/*  Instruction processer combines loader, decoder, resolver, and issue_busr into one block to ease the cpu module complexity
*/
import global_variables::XLEN;
import structures::*;

module instr_processer (
    global_bus_if.rest global_bus,
    pc_bus_if.loader pc_bus,
    instr_cache_bus_if.loader cache_bus[2],
    reg_query_bus_if.resolver query_bus[2],
    fullness_bus_if.issuer fullness,
    issue_bus_if.cmp issue_bus[2],
    reg_val_bus_if.cmp reg_val_bus[2],
    common_data_bus_if.cmp data_bus[2]
);
  // ------------------------------- Wires -------------------------------
  instr_info_bus_if dec_to_ren[2] ();
  instr_info_bus_if ren_to_res[2] ();
  instr_info_bus_if res_to_issue[2] ();
  instr_info_bus_if issue_to_cmp[2] ();

  instr_proc_if instr_proc ();

  jmp_relation_e jmp_relation;

  logic [XLEN-1:0] load_address_out[2];
  logic [31:0] load_instr_out[2];

  // ------------------------------- Modules -------------------------------
  loader loader (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .cache_bus(cache_bus),
      .instr_proc(instr_proc),
      .address(load_address_out),
      .instr(load_instr_out)
  );

  decoder decoder_0 (
      .global_bus(global_bus),
      .instr_info(dec_to_ren[0]),
      .address(load_address_out[0]),
      .instr(load_instr_out[0]),
      .instr_proc(instr_proc)
  );

  decoder decoder_1 (
      .global_bus(global_bus),
      .instr_info(dec_to_ren[1]),
      .address(load_address_out[1]),
      .instr(load_instr_out[1]),
      .instr_proc(instr_proc)
  );

  renamer renamer (
      .global_bus(global_bus),
      .query_bus(query_bus),
      .instr_info_in(dec_to_ren),
      .instr_info_out(ren_to_res),
      .jmp_relation(jmp_relation),
      .instr_proc(instr_proc)
  );

  resolver resolver (
      .global_bus(global_bus),
      .query_bus(query_bus),
      .instr_info_in(ren_to_res),
      .instr_info_out(res_to_issue),
      .jmp_relation(jmp_relation),
      .instr_proc(instr_proc)
  );

  issuer issuer (
      .global_bus(global_bus),
      .instr_info_in(res_to_issue),
      .instr_info_out(issue_to_cmp),
      .fullness(fullness),
      .instr_proc(instr_proc)
  );

  comparator comparator_0 (
      .instr_info(issue_to_cmp[0]),
      .issue_bus(issue_bus[0]),
      .reg_val_bus(reg_val_bus[0]),
      .data_bus(data_bus)
  );

  comparator comparator_1 (
      .instr_info(issue_to_cmp[1]),
      .issue_bus(issue_bus[1]),
      .reg_val_bus(reg_val_bus[1]),
      .data_bus(data_bus)
  );

  // ------------------------------- Behaviour -------------------------------
  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_wire_clear
      always_comb begin
        if (global_bus.reset) begin
          dec_to_ren[i].clear();
          ren_to_res[i].clear();
          res_to_issue[i].clear();
          issue_to_cmp[i].clear();
          issue_bus[i].clear();
        end
      end
    end
  endgenerate
endmodule

