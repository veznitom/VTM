/*  Resolver checks for dependencies between loaded instructions and requests register renaming if instructions writes,
if there is no free register for rename then it stalls the loader and decoder
*/

module resolver #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    reg_query_bus_if.resolver query[2],
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],

    input  logic stop_in,
    output logic stop_out
);

  instr_types_e instr_type;

  logic tag_active;

  function automatic bit match_regs(input logic [5:0] rd, input logic [5:0] rs);
    return (rd != 6'h00 && rd == rs);
  endfunction

  always_ff @(posedge global_bus.clock) begin : fetch
    if (!stop_in && instr_info_in[0].instr_name != UNKNOWN
    && instr_info_in[1].instr_name != UNKNOWN) begin
      case ({
        instr_info_in[0].flags.jumps, instr_info_in[1].flags.jumps
      })
        2'b00:   instr_type <= NJ1NJ2;
        2'b01:   instr_type <= NJ1J2;
        2'b10:   instr_type <= J1NJ2;
        2'b11:   instr_type <= J1J2;
        default: instr_type <= ERROR;
      endcase


      query[0].inputs.rs_1 <= instr_info_in[0].regs.rs_1;
      query[0].inputs.rs_2 <= instr_info_in[0].regs.rs_2;
      query[0].inputs.rd   <= instr_info_in[0].regs.rd;
      if (instr_info_in[0].flags.writes) query[0].rename <= 1'h1;
      else query[0].rename <= 1'h0;
      query[0].tag <= tag_active;

      query[1].inputs.rs_1 <= instr_info_in[1].regs.rs_1;
      query[1].inputs.rs_2 <= instr_info_in[1].regs.rs_2;
      query[1].inputs.rd <= instr_info_in[1].regs.rd;
      if (instr_info_in[1].flags.writes) query[1].rename <= 1'h1;
      else query[1].rename <= 1'h0;
      query[1].tag <= tag_active;

      stop_out <= 1'h1;
    end

    if (stop_out) begin
      instr_info_out[0].address <= instr_info_in[0].address;
      instr_info_out[0].immediate <= instr_info_in[0].immediate;
      instr_info_out[0].instr_name <= instr_info_in[0].instr_name;
      instr_info_out[0].regs.rs_1 <= query[0].outputs.rs_1;
      instr_info_out[0].regs.rs_2 <= query[0].outputs.rs_2;
      instr_info_out[0].regs.rd <= instr_info_in[0].regs.rd;
      if (instr_info_in[0].flags.writes && instr_info_in[0].regs.rd != 5'h0)
        instr_info_out[0].regs.rn <= query[0].outputs.rn;
      else instr_info_out[0].regs.rn <= 6'h00;
      instr_info_out[0].st_type <= instr_info_in[0].st_type;
      instr_info_out[0].flags <= instr_info_in[0].flags;
      instr_info_out[0].flags.tag <= instr_info_in[0].flags.jumps ? 1'b0 : tag_active;

      instr_info_out[1].address <= instr_info_in[1].address;
      instr_info_out[1].immediate <= instr_info_in[1].immediate;
      instr_info_out[1].instr_name <= instr_info_in[1].instr_name;
      if (match_regs(instr_info_in[0].regs.rd, instr_info_in[1].regs.rs_1))
        instr_info_out[1].regs.rs_1 <= query[0].outputs.rn;
      else instr_info_out[1].regs.rs_1 <= query[1].outputs.rs_1;
      if (match_regs(instr_info_in[0].regs.rd, instr_info_in[1].regs.rs_2))
        instr_info_out[1].regs.rs_2 <= query[0].outputs.rn;
      else instr_info_out[1].regs.rs_2 <= query[1].outputs.rs_2;
      instr_info_out[1].regs.rd <= instr_info_in[1].regs.rd;
      if (instr_info_in[1].flags.writes && instr_info_in[1].regs.rd != 6'h00)
        instr_info_out[1].regs.rn <= query[1].outputs.rn;
      else instr_info_out[1].regs.rn <= 6'h00;
      instr_info_out[1].st_type <= instr_info_in[1].st_type;
      instr_info_out[1].flags   <= instr_info_in[1].flags;
      if (instr_info_in[1].flags.jumps) instr_info_out[1].flags.tag <= 1'b0;
      else if (instr_info_in[0].flags.jumps) instr_info_out[1].flags.tag <= 1'b1;
      else instr_info_out[1].flags.tag <= tag_active;

      stop_out <= 1'h0;
    end
  end
endmodule

