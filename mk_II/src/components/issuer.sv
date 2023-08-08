/*  Controls if destination stations or reorder buffer has enough space to hold another instructions, if they do then the instructions are issued otherwise,
    issuer halts and waits for them to free up (halt also stops loader, decoder, resolver unless there is bubble in the form of zero instruction).
*/

import structures::*;

module issuer #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],
    fullness_bus_if.issuer fullness,

    output logic stop
);
  logic stops[2];
  logic fullness_split[5];

  assign fullness_split[AL] = fullness.alu;
  assign fullness_split[BR] = fullness.branch;
  assign fullness_split[LS] = fullness.load_store;
  assign fullness_split[RB] = fullness.rob;
  assign fullness_split[MD] = fullness.mult_div;

  assign stop = stops[0] | stops[1] | 1'h0;

  always_comb begin : reset
    if (global_bus.reset) stop = 1'h0;
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_instr_info
      always_ff @(posedge global_bus.clock) begin : issue
        if (instr_info_in[0].instr_name != UNKNOWN && instr_info_in[1].instr_name != UNKNOWN) begin
          if (!fullness_split[instr_info_in[0].st_type] && !fullness_split[instr_info_in[1].st_type]
          && !fullness_split[RB]) begin
            instr_info_out[i].address <= instr_info_in[i].address;
            instr_info_out[i].immediate <= instr_info_in[i].immediate;
            instr_info_out[i].instr_name <= instr_info_in[i].instr_name;
            instr_info_out[i].st_type <= instr_info_in[i].st_type;
            instr_info_out[i].regs <= instr_info_in[i].regs;
            instr_info_out[i].flags <= instr_info_in[i].flags;
            stops[i] <= 1'h0;
          end else stops[i] <= 1'h1;
        end else stops[i] <= 1'h0;
      end
    end
  endgenerate

endmodule
