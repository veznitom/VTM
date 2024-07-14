module ip_loader #(
    parameter logic [31:0] RESET_VECTOR = '0
) (
    input clock,
    input reset,

    input wire [31:0] cache_instr[2],
    input wire cache_hit[2],
    output reg [31:0] cache_address[2],
    output reg cache_read[2],

    output reg [31:0] address[2],
    output reg [31:0] instr  [2],

    input wire halt
);
  // ------------------------------- Regs -------------------------------
  reg [31:0] pc;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin : pc_bus_reset
    if (reset) begin
      pc = {32{1'h0}};
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_var_reset

      assign cache_address[i] = pc + (i * 4);
      assign cache_read[i] = halt ? 1'b0 : 1'b1;

      always_comb begin
        if (reset) begin
          address[i] = {32{1'h0}};
          instr[i]   = {32{1'h0}};
        end
      end
    end
  endgenerate

  always_ff @(posedge clock) begin : instr_load
    if (!halt)
      if (cache_hit[0] && cache_hit[1]) begin
        address[0] <= pc;
        address[1] <= pc + 4;
        instr[0] <= cache_instr[0];
        instr[1] <= cache_instr[1];
        pc <= pc + 8;
      end else begin
        address[0] <= {32{1'h0}};
        address[1] <= {32{1'h0}};
        instr[0]   <= {32{1'h0}};
        instr[1]   <= {32{1'h0}};
      end
  end
endmodule
