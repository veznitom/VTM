// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module RegisterFile (
  IntfCSB.tag                cs,
  IntfRegQuery.RegisterFile  query  [2],
  IntfRegValBus.RegisterFile reg_val[2],
  IntfCDB.RegisterFile       data   [2]
);
  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [31:0] value;
    bit [5:0]    rrn;
    bit          valid, tag;
  } register_t;

  // ------------------------------- Wires -------------------------------
  register_t        registers[64];
  logic      [31:0] ren_free;
  logic [5:0] query_rename[2], rd_sync[2];
  logic query_ren_en[2];
  // ------------------------------- Modules -------------------------------
  RenameManager u_ren_man ();

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : reset
    if (cs.reset) begin
      foreach (registers[j]) begin
        registers[j] = '{0, 0, 0, 0};
      end
      ren_free = 32'h00000000;
    end
  end

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_q_rn_clear
      assign query[i].outputs.rd = 6'h0;

      assign query[i].outputs.rn = query_rename[i];
      assign query_ren_en[i]     = query[i].rename;
      assign rd_sync[i]          = query[i].inputs.rd;

      always_comb begin : data_return
        reg_val[i].data_1  = registers[reg_val[i].src_1].value;
        reg_val[i].valid_1 = registers[reg_val[i].src_1].valid;
        reg_val[i].data_2  = registers[reg_val[i].src_2].value;
        reg_val[i].valid_2 = registers[reg_val[i].src_2].valid;
      end

      always_comb begin
        if (registers[query[i].inputs.rs_1].rrn != 00) begin
          query[i].outputs.rs_1 = registers[query[i].inputs.rs_1];
        end else query[i].outputs.rs_1 = query[i].inputs.rs_1;

        if (registers[query[i].inputs.rs_2].rrn != 00) begin
          query[i].outputs.rs_2 = registers[query[i].inputs.rs_2];
        end else query[i].outputs.rs_2 = query[i].inputs.rs_2;
      end

      always_comb begin : renaming
        if (query[i].rename) begin
          registers[query[i].inputs.rd].rrn = query[i].outputs.rn;
          registers[query[i].outputs.rn]    = '{0, 0, 0, query[i].tag};
          if (!query[i].tag) registers[query[i].inputs.rd].valid = 1'h0;
          registers[query[i].inputs.rd].tag = query[i].tag;
        end
      end

      always_ff @(posedge cs.clock) begin : data_update
        if (data_bus[i].reg_write) begin
          if (data_bus[i].arn == 6'h00) begin : from_exec
            registers[data_bus[i].rrn].value <= data_bus[i].result;
            registers[data_bus[i].rrn].valid <= 1'h1;
          end else if (data_bus[i].arn != 6'h00) begin : from_rob
            if (data_bus[i].rrn == registers[data_bus[i].arn].rrn) begin : nren
              registers[data_bus[i].arn].value <= data_bus[i].result;
              registers[data_bus[i].arn].valid <= 1'h1;
              registers[data_bus[i].arn].tag   <= 1'h0;
              registers[data_bus[i].arn].rrn   <= 6'h00;
            end else begin : was_re_renamed
              registers[data_bus[i].arn].value <= data_bus[i].result;
              registers[data_bus[i].arn].valid <= 1'h1;
            end
            registers[data_bus[i].rrn]                  <= '{0, 0, 0, 0};
            // might need zeroing
            ren_free[registers[data_bus[i].arn].rrn-32] <= 1'h1;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge cs.clock) begin : clear_tagged
    if (cs.clear_tag) begin
      foreach (registers[i]) begin
        if (registers[i].tag) registers[i].tag <= 1'h0;
      end
    end
  end

  always_ff @(posedge cs.clock) begin : delete_tagged
    if (cs.delete_tag) begin
      for (int i = 0; i < 32; i++) begin
        if (registers[i].tag) begin
          registers[i].tag <= 1'h0;
          registers[i].rrn <= 1'h0;
        end
      end
    end

    for (int i = 32; i < 64; i++) begin
      if (registers[i].tag) begin
        registers[i]   <= '{0, 0, 0, 0};
        ren_free[i-32] <= 1'h1;  // might need zeroing
      end
    end
  end
endmodule
