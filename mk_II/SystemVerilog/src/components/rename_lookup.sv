import global_variables::XLEN;
import structures::*;

module rename_lookup (
    input logic clock,
    input logic reset,
    input logic ren_enable[2],
    input logic [31:0] ren_free,
    input logic [5:0] rd_sync[2],
    output logic [5:0] ren_num[2]
);
  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [5:0] name;
    logic in_use;
  } renamed_t;

  // ------------------------------- Wires -------------------------------
  renamed_t renames[32];
  logic [31:0] select;

  // ------------------------------- Behaviour -------------------------------
  genvar i;
  generate
    for (i = 0; i < 32; i++) begin : gen_connects
      assign select[i] = renames[i].in_use;

      always_comb begin : out_reset
        if (reset) begin
          ren_num[i] = 6'h00;
        end
      end
    end
  endgenerate

  always_comb begin
    if (reset) begin
      for (int i = 32; i < 64; i++) begin
        renames[i-32] = '{i, 1'h0};
      end
    end
  end

/*
  THIS WILL DEFINITELY BREAK WHEN TWO INSTRUCTIONS THAT WRITE INTO THE SAME REGISTER ARE ONE AFTER OTHER
  NEED FIXING !!!!
*/

  always_comb begin : ret_ren
    if (ren_enable[0] && rd_sync[0] > 0)
      for (int i = 0; i < 32; i++) begin
        if (!renames[i].in_use) begin
          renames[i].in_use = 1'h1;
          ren_num[0] = renames[i].name;
          break;
        end
      end

    if (ren_enable[1] && rd_sync[1] > 0)
      for (int i = 0; i < 32; i++) begin
        if (!renames[i].in_use) begin
          renames[i].in_use = 1'h1;
          ren_num[1] = renames[i].name;
          break;
        end
      end
  end

  always_ff @(posedge clock) begin : free_named
    for (int i = 0; i < 32; i++) begin
      if (ren_free[i] && !reset) renames[i].in_use <= 1'h0;
    end
  end
endmodule
