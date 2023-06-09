/*  Controls if destination stations or reorder buffer has enough space to hold another instructions, if they do then the instructions are issued otherwise,
    issuer halts and waits for them to free up (halt also stops loader, decoder, resolver unless there is bubble in the form of zero instruction).
*/

module issuer #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    instr_issue_if iii, //temp

    input logic [XLEN-1:0] addresses_in[2],
    input logic [XLEN-1:0] immediates_in[2],
    input instr_name_e instr_names_in[2],
    input instr_type_e instr_types_in[2],
    input src_dest_t regs_in[2],
    input flag_vector_t flags_in[2],

    input logic [2:0] st_fullness,

    output logic stop
);
    TODO();
endmodule
