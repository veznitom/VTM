/*  Resolver checks for dependencies between loaded instructions and requests register renaming if instructions writes,
if there is no free register for rename then it stalls the loader and decoder
*/
import global_variables::XLEN;
import structures::*;

module resolver (
    global_bus_if.rest global_bus,
    reg_query_bus_if.resolver query_bus[2],
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],
    instr_proc_if.resolver instr_proc,

    input jmp_relation_e jmp_relation
);
  function automatic bit match_regs(input logic [5:0] rd, input logic [5:0] rs);
    return (rd != 6'h00 && rd == rs);
  endfunction

  logic tag_active;

  always_comb begin : reset
    if (global_bus.reset) begin
      tag_active = 1'h0;
    end
  end

  always_comb begin : stops
    if (instr_info_in[0].instr_name != UNKNOWN && instr_info_in[1].instr_name != UNKNOWN)
      if ((instr_info_in[0].flags.writes && query_bus[0].outputs.rn == 6'h00)
      || (instr_info_in[1].flags.writes && query_bus[1].outputs.rn == 6'h00))
        instr_proc.resolver_stop = 1'h1;
      else instr_proc.resolver_stop = 1'h0;
    else instr_proc.resolver_stop = 1'h0;
  end

  always_ff @(posedge global_bus.clock) begin : fetch
    if (
      !instr_proc.issuer_stop &&
      instr_info_in[0].instr_name != UNKNOWN &&
      instr_info_in[1].instr_name != UNKNOWN)
    begin
      instr_info_out[0].address <= instr_info_in[0].address;
      instr_info_out[0].immediate <= instr_info_in[0].immediate;
      instr_info_out[0].instr_name <= instr_info_in[0].instr_name;
      instr_info_out[0].regs.rs_1 <= query_bus[0].outputs.rs_1;
      instr_info_out[0].regs.rs_2 <= query_bus[0].outputs.rs_2;
      instr_info_out[0].regs.rd <= instr_info_in[0].regs.rd;
      if (instr_info_in[0].flags.writes && instr_info_in[0].regs.rd != 5'h0)
        instr_info_out[0].regs.rn <= query_bus[0].outputs.rn;
      else instr_info_out[0].regs.rn <= 6'h00;
      instr_info_out[0].instr_type <= instr_info_in[0].instr_type;
      instr_info_out[0].flags <= instr_info_in[0].flags;
      instr_info_out[0].flags.tag <= instr_info_in[0].flags.jumps ? 1'b0 : tag_active;

      instr_info_out[1].address <= instr_info_in[1].address;
      instr_info_out[1].immediate <= instr_info_in[1].immediate;
      instr_info_out[1].instr_name <= instr_info_in[1].instr_name;
      if (match_regs(instr_info_in[0].regs.rd, instr_info_in[1].regs.rs_1))
        instr_info_out[1].regs.rs_1 <= query_bus[0].outputs.rn;
      else instr_info_out[1].regs.rs_1 <= query_bus[1].outputs.rs_1;
      if (match_regs(instr_info_in[0].regs.rd, instr_info_in[1].regs.rs_2))
        instr_info_out[1].regs.rs_2 <= query_bus[0].outputs.rn;
      else instr_info_out[1].regs.rs_2 <= query_bus[1].outputs.rs_2;
      instr_info_out[1].regs.rd <= instr_info_in[1].regs.rd;
      if (instr_info_in[1].flags.writes && instr_info_in[1].regs.rd != 6'h00)
        instr_info_out[1].regs.rn <= query_bus[1].outputs.rn;
      else instr_info_out[1].regs.rn <= 6'h00;
      instr_info_out[1].instr_type <= instr_info_in[1].instr_type;
      instr_info_out[1].flags <= instr_info_in[1].flags;
      if (instr_info_in[1].flags.jumps) instr_info_out[1].flags.tag <= 1'b0;
      else if (instr_info_in[0].flags.jumps) instr_info_out[1].flags.tag <= 1'b1;
      else instr_info_out[1].flags.tag <= tag_active;
    end
  end
endmodule

