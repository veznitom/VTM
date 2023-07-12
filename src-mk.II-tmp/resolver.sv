/*  Resolver checks for dependencies between loaded instructions and requests register renaming if instructions writes,
if there is no free register for rename then it stalls the loader and decoder
*/

module resolver #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    register_query_if query[2],

    input logic [XLEN-1:0] addresses_in[2],
    input logic [XLEN-1:0] immediates_in[2],
    input instr_name_e instr_names_in[2],
    input instr_type_e instr_types_in[2],
    input src_dest_t regs_in[2],
    input flag_vector_t flags_in[2],
    input logic stop_in,

    output logic [XLEN-1:0] addresses_out[2],
    output logic [XLEN-1:0] immediates_out[2],
    output instr_name_e instr_names_out[2],
    output instr_type_e instr_types_out[2],
    output src_dest_t regs_out[2],
    output flag_vector_t flags_out[2],
    output logic stop_out
);
    TODO();
endmodule

