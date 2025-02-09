// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module WriteBuffer #(
  parameter int BUFFER_SIZE_BITS = 4
) (
  IntfCSB.tag             cs,
  IntfDataCache.Cache     load_store,
  IntfDataCache.LoadStore cache,
  IntfCDB.Cache           data      [2]
);
  // ------------------------------- Structures -------------------------------
  typedef struct packed {logic [31:0] data, address;} wb_record_t;

  // ------------------------------- Wires -------------------------------
  wb_record_t buffer[2**BUFFER_SIZE_BITS];
  logic [BUFFER_SIZE_BITS-1:0] read_index, write_index;
  // ------------------------------- Behaviour -------------------------------
  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      foreach (buffer[i]) buffer[i] <= '{'0, '0, '0, '0};
      read_index  <= '0;
      write_index <= '0;
    end else begin
      
    end
  end
endmodule
