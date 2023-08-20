import structures::*;

module renamer #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    reg_query_bus_if.resolver query_bus[2],
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],

    input logic stop,
    output jmp_relation_e jmp_relation
);

  logic tag_active;

  always_comb begin : reset
    if (global_bus.reset) begin
      tag_active = 1'h0;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_q_rn_clear
      assign query_bus[i].inputs.rn = 6'h0;

      always_comb begin
        if (global_bus.reset) query_bus[i].clear();
      end

      always_ff @(posedge global_bus.clock) begin : relay
        if (!stop) begin
          instr_info_out[i].address <= instr_info_in[i].address;
          instr_info_out[i].immediate <= instr_info_in[i].immediate;
          instr_info_out[i].instr_name <= instr_info_in[i].instr_name;
          instr_info_out[i].regs <= instr_info_in[i].regs;
          instr_info_out[i].instr_type <= instr_info_in[i].instr_type;
          instr_info_out[i].flags <= instr_info_in[i].flags;
        end else instr_info_out[i].clear();
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : fetch
    if (!stop)
      if (instr_info_in[0].instr_name != UNKNOWN && instr_info_in[1].instr_name != UNKNOWN) begin
        case ({
          instr_info_in[0].flags.jumps, instr_info_in[1].flags.jumps
        })
          2'b00:   jmp_relation <= NJ1NJ2;
          2'b01:   jmp_relation <= NJ1J2;
          2'b10:   jmp_relation <= J1NJ2;
          2'b11:   jmp_relation <= J1J2;
          default: jmp_relation <= ERROR;
        endcase

        query_bus[0].inputs.rs_1 <= instr_info_in[0].regs.rs_1;
        query_bus[0].inputs.rs_2 <= instr_info_in[0].regs.rs_2;
        query_bus[0].inputs.rd   <= instr_info_in[0].regs.rd;
        if (instr_info_in[0].flags.writes) query_bus[0].rename <= 1'h1;
        else query_bus[0].rename <= 1'h0;
        query_bus[0].tag <= tag_active;

        query_bus[1].inputs.rs_1 <= instr_info_in[1].regs.rs_1;
        query_bus[1].inputs.rs_2 <= instr_info_in[1].regs.rs_2;
        query_bus[1].inputs.rd <= instr_info_in[1].regs.rd;
        if (instr_info_in[1].flags.writes) query_bus[1].rename <= 1'h1;
        else query_bus[1].rename <= 1'h0;
        query_bus[1].tag <= tag_active;
      end else begin
        query_bus[0].clear();
        query_bus[1].clear();
        jmp_relation <= ERROR;
      end
  end
endmodule

