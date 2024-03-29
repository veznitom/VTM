// Manages loading instructions from instr cache, if there is cache miss padds output instructions with zeroes
import global_variables::XLEN;

module loader (
    global_bus_if.rest global_bus,
    pc_bus_if.loader pc_bus,
    instr_cache_bus_if.loader cache_bus[2],
    instr_proc_if.loader instr_proc,

    output logic [XLEN-1:0] address[2],
    output logic [31:0] instr[2]
);
  // ------------------------------- Wires -------------------------------
  logic [XLEN-1:0] pc;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin : pc_bus_reset
    if (global_bus.reset) begin
      pc = {XLEN{1'h0}};
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_var_reset

      assign cache_bus[i].address_in = pc + (i * 4);
      assign cache_bus[i].read = instr_proc.stop ? 1'b0 : 1'b1;

      always_comb begin
        if (global_bus.reset) begin
          address[i] = {XLEN{1'h0}};
          instr[i]   = {32{1'h0}};
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : instr_load
    if (!instr_proc.stop)
      if (cache_bus[0].hit && cache_bus[1].hit) begin
        address[0] <= pc;
        address[1] <= pc + 4;
        instr[0] <= cache_bus[0].instr;
        instr[1] <= cache_bus[1].instr;
        pc <= pc + 8;
      end else begin
        address[0] <= {XLEN{1'h0}};
        address[1] <= {XLEN{1'h0}};
        instr[0]   <= {32{1'h0}};
        instr[1]   <= {32{1'h0}};
      end
  end
endmodule
