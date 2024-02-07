import global_variables::XLEN;
import structures::*;

module renames (
    input logic rename[2],
    input logic free[32],
    output logic [5:0] name
);
  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [5:0] renames;
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
    end
  endgenerate

  always_comb begin : free_ren
    for (int i = 0; i < 32; i++) begin
      if (free[i]) renames[i].in_use = 1'h0;
    end
  end

  always_comb begin : ret_ren
    casez (select)
      default: 
    endcase
  end
endmodule
