// Manages loading instructions from instr cache, if there is cache miss padds output instructions with zeroes

module loader #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    input logic [XLEN-1:0] address_in[2],
    input logic [31:0] instr_in[2],
    input logic [1:0] hit,
    input logic stop,
    output logic [XLEN-1:0] address_out[2],
    output logic [31:0] instr_out[2]
);
  TODO();
endmodule
