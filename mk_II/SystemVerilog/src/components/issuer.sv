/*  Controls if destination stations or reorder buffer has enough space to hold another instructions, if they do then the instructions are issued otherwise,
    issuer halts and waits for them to free up (halt also stops loader, decoder, resolver unless there is bubble in the form of zero instruction).
*/
import structures::*;

module issuer (
    global_bus_if.rest global_bus,
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],
    fullness_bus_if.issuer fullness,
    instr_proc_if.issuer instr_proc
);
  // ------------------------------- Wires -------------------------------
  logic fullness_split[6];

  // ------------------------------- Behaviour -------------------------------
  assign fullness_split[AL] = fullness.alu;
  assign fullness_split[BR] = fullness.branch;
  assign fullness_split[LS] = fullness.load_store;
  assign fullness_split[RB] = fullness.rob;
  assign fullness_split[MD] = fullness.mult_div;
  assign fullness_split[XX] = 1'h0;

  assign instr_proc.issuer_stop =
    fullness_split[instr_info_in[0].instr_type] |
    fullness_split[instr_info_in[1].instr_type] |
    fullness_split[RB];

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_instr_info
      always_ff @(posedge global_bus.clock) begin : issue
        if (!instr_proc.issuer_stop) begin
          instr_info_out[i].address <= instr_info_in[i].address;
          instr_info_out[i].immediate <= instr_info_in[i].immediate;
          instr_info_out[i].instr_name <= instr_info_in[i].instr_name;
          instr_info_out[i].instr_type <= instr_info_in[i].instr_type;
          instr_info_out[i].regs <= instr_info_in[i].regs;
          instr_info_out[i].flags <= instr_info_in[i].flags;
        end
      end
    end
  endgenerate
endmodule
