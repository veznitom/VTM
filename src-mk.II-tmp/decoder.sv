// Translates instructions based on RISC-V instruction encoding

module decoder #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,

    input logic [XLEN-1:0] address_in,
    input logic [31:0] instr,
    input logic stop,

    output logic [XLEN-1:0] address_out,
    output logic [XLEN-1:0] immediate,
    output instr_name_e instr_name,
    output instr_type_e instr_type,
    output src_dest_t regs,
    output flag_vector_t flags
);
  TODO();
endmodule
