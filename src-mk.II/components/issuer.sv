/*  Controls if destination stations or reorder buffer has enough space to hold another instructions, if they do then the instructions are issued otherwise,
    issuer halts and waits for them to free up (halt also stops loader, decoder, resolver unless there is bubble in the form of zero instruction).
*/

module issuer #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    instr_issue_if issue[2],
    instr_info_if instr_info[2],
    input logic [2:0] st_fullness,
    output logic stop
);
    TODO();
endmodule
