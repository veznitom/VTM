import pkg_structures::*;

`include "ip_comparator.sv"
`include "ip_control.sv"
`include "ip_decoder.sv"
`include "ip_issuer.sv"
`include "ip_loader.sv"
`include "ip_resolver.sv"

module ip_wrapper (
    input clock,
    input reset,

    input wire [31:0] cache_instr[2],
    input wire cache_hit[2],
    output reg [31:0] cache_address[2],
    output reg cache_read[2],

    reg_query_bus_if.resolver query_bus[2],
    reg_val_bus_if.cmp reg_val_bus[2],

    fullness_bus_if.issuer fullness,
    issue_bus_if.cmp issue_bus[2],
    common_data_bus_if.cmp data_bus[2]
);
  // ------------------------------- Wires -------------------------------
  logic [31:0] address[4], immediate[4];
  instr_name_e instr_name[4];
  instr_type_e instr_type[4];
  registers_t regs[4];
  flag_vector_t flags[4];

  jmp_relation_e jmp_relation;

  logic [31:0] load_address_out[2];
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

