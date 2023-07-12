module instr_cache #(
    parameter int SIZE = 1024,
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    instr_cache_bus_if instr_bus,

    input logic [XLEN-1:0] pc,

    output logic [XLEN-1] addresses[2],
    output logic [31:0] instrs[2],
    output logic [1:0] hit
);
    TODO();
endmodule
