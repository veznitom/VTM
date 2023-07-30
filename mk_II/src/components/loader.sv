// Manages loading instructions from instr cache, if there is cache miss padds output instructions with zeroes

module loader #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    pc_interface_if pc_if,
    input logic [XLEN-1:0] address_in[2],
    input logic [31:0] instr_in[2],
    input logic [1:0] hit,
    input logic stop,
    output logic [XLEN-1:0] address_out[2],
    output logic [31:0] instr_out[2]
);

  always_ff @(posedge gsi.clk) begin : instr_load
    if (!stop && hit[0] && hit[1]) begin
      address_out[0] <= address_in[0];
      instr_out[0]   <= instr_in[0];
      address_out[1] <= address_in[1];
      instr_out[1]   <= instr_in[1];
      pc_if.plus_8   <= 1'h1;
    end else begin
      pc_if.plus_8 <= 1'h0;
    end
  end
endmodule
