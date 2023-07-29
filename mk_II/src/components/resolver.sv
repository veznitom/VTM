/*  Resolver checks for dependencies between loaded instructions and requests register renaming if instructions writes,
if there is no free register for rename then it stalls the loader and decoder
*/

module resolver #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    register_query_if query[2],
    instr_info_if instr_info_in[2], instr_info_out[2],
    inout logic stop
);
  TODO();
endmodule

