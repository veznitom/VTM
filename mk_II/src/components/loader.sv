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

  typedef struct packed {
    logic [1:0][XLEN-1:0] address;
    logic [1:0][31:0] instr;
    logic [1:0] ready;
  } loaded_instr_t;

  loaded_instr_t loaded[2];

  always_comb begin : reset
    if (gsi.reset || gsi.delete_tagged) begin
      loaded[0].ready = 1'h0;
      loaded[1].ready = 1'h0;
    end
  end

  always_ff @(posedge gsi.clk) begin : instr_load
    if (hit[0]) begin
      loaded[0].address <= address_in[0];
      loaded[0].instr   <= instr_in[0];
      loaded[0].ready   <= 1'h1;
    end else loaded[0].ready <= 1'h0;

    if (hit[1]) begin
      loaded[1].address <= address_in[1];
      loaded[1].instr   <= instr_in[1];
      loaded[1].ready   <= 1'h1;
    end else loaded[1].ready <= 1'h0;
  end

  always_ff @(posedge gsi.clk) begin : instr_forward
    if (loaded[0].ready && loaded[1].ready && !stop) begin
      address_out[0] <= loaded[0].address;
      instr_out[0]   <= loaded[0].instr;
      address_out[1] <= loaded[1].address;
      instr_out[1]   <= loaded[1].instr;
      pc_if.plus_8   <= 1'h1;
    end else pc_if.plus_8 <= 1'h0;
  end

endmodule
