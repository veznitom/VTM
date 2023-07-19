// Translates instructions based on RISC-V instruction encoding

module decoder #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    instr_info_if instr_info,
    input logic [XLEN-1:0] address_in,
    input logic [31:0] instr,
    input logic stop
);
  TODO();
endmodule
