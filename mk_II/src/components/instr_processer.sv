/*  Instruction processer combines loader, decoder, resolver, and issue_busr into one block to ease the cpu module complexity
*/
import structures::*;

module instr_processer #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    pc_bus_if.loader pc_bus,
    instr_cache_bus_if.loader cache_bus[2],
    reg_query_bus_if.resolver query_bus[2],
    fullness_bus_if.issuer fullness,
    issue_bus_if.cmp issue_bus[2],
    reg_val_bus_if.cmp reg_val_bus[2],
    common_data_bus_if.cmp data_bus[2]
);
  instr_info_bus_if dec_to_res[2] ();
  instr_info_bus_if res_to_issue[2] ();
  instr_info_bus_if issue_to_cmp[2] ();

  logic [XLEN-1:0] load_address_out[2];
  logic [31:0] load_instr_out[2];
  logic stop_res, stop_iss, stop;

  loader #(
      .XLEN(XLEN)
  ) loader (
      .global_bus(global_bus),
      .pc_bus(pc_bus),
      .cache_bus(cache_bus),
      .stop(stop),
      .address(load_address_out),
      .instr(load_instr_out)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_0 (
      .global_bus(global_bus),
      .instr_info(dec_to_res[0]),
      .address(load_address_out[0]),
      .instr(load_instr_out[0]),
      .stop(stop)
  );

  decoder #(
      .XLEN(XLEN)
  ) decoder_1 (
      .global_bus(global_bus),
      .instr_info(dec_to_res[1]),
      .address(load_address_out[1]),
      .instr(load_instr_out[1]),
      .stop(stop)
  );

  resolver #(
      .XLEN(XLEN)
  ) resolver (
      .global_bus(global_bus),
      .query_bus(query_bus),
      .instr_info_in(dec_to_res),
      .instr_info_out(res_to_issue),
      .stop_in(stop),
      .stop_out(stop_res)
  );

  issuer #(
      .XLEN(XLEN)
  ) issuer (
      .global_bus(global_bus),
      .instr_info_in(res_to_issue),
      .instr_info_out(issue_to_cmp),
      .fullness(fullness),
      .stop(stop_iss)
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

  assign stop = stop_res | stop_iss | 1'h0;

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_wire_clear
      always_comb begin
        if (global_bus.reset) begin
          dec_to_res[i].clear();
          res_to_issue[i].clear();
          issue_to_cmp[i].clear();
        end
      end
    end
  endgenerate
endmodule

