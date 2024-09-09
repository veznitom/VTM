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
  register_t registers[64];
  logic [5:0] query_rename[2], rd_sync[2];
  logic query_ren_en[2];
  // ------------------------------- Modules -------------------------------

  // ------------------------------- Behaviour -------------------------------
  /*
  assign query[0].outputs.rd = 6'h0;
  assign query[1].outputs.rd = 6'h0;

  assign query[0].outputs.rn = query_rename[0];
  assign query[1].outputs.rn = query_rename[1];
  assign query_ren_en[0]     = query[0].rename;
  assign query_ren_en[1]     = query[1].rename;
  assign rd_sync[0]          = query[0].inputs.rd;
  assign rd_sync[1]          = query[1].inputs.rd;

  always_comb begin : data_return
    reg_val[0].data_1  = registers[reg_val[0].src_1].value;
    reg_val[0].valid_1 = registers[reg_val[0].src_1].valid;
    reg_val[0].data_2  = registers[reg_val[0].src_2].value;
    reg_val[0].valid_2 = registers[reg_val[0].src_2].valid;

    reg_val[1].data_1  = registers[reg_val[1].src_1].value;
    reg_val[1].valid_1 = registers[reg_val[1].src_1].valid;
    reg_val[1].data_2  = registers[reg_val[1].src_2].value;
    reg_val[1].valid_2 = registers[reg_val[1].src_2].valid;
  end

  always_comb begin
    if (registers[query[0].inputs.rs_1].rrn != 00) begin
      query[0].outputs.rs_1 = registers[query[0].inputs.rs_1];
    end else query[0].outputs.rs_1 = query[0].inputs.rs_1;

    if (registers[query[1].inputs.rs_1].rrn != 00) begin
      query[1].outputs.rs_1 = registers[query[1].inputs.rs_1];
    end else query[1].outputs.rs_1 = query[1].inputs.rs_1;

    if (registers[query[0].inputs.rs_2].rrn != 00) begin
      query[0].outputs.rs_2 = registers[query[0].inputs.rs_2];
    end else query[0].outputs.rs_2 = query[0].inputs.rs_2;

    if (registers[query[1].inputs.rs_2].rrn != 00) begin
      query[1].outputs.rs_2 = registers[query[1].inputs.rs_2];
    end else query[1].outputs.rs_2 = query[1].inputs.rs_2;
  end

  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      foreach (registers[j]) begin
        registers[j] <= '{0, 0, 0, 0};
      end
    end else begin
      // renaming
      if (query[0].rename) begin
        registers[query[0].inputs.rd].rrn <= query[0].outputs.rn;
        registers[query[0].outputs.rn]    <= '{0, 0, 0, query[0].tag};
        if (!query[0].tag) registers[query[0].inputs.rd].valid <= 1'h0;
        registers[query[0].inputs.rd].tag <= query[0].tag;
      end

      if (query[1].rename) begin
        registers[query[1].inputs.rd].rrn <= query[1].outputs.rn;
        registers[query[1].outputs.rn]    <= '{0, 0, 0, query[1].tag};
        if (!query[1].tag) registers[query[1].inputs.rd].valid <= 1'h0;
        registers[query[1].inputs.rd].tag <= query[1].tag;
      end

      // data_update
      if (data[0].reg_write) begin
        if (data[0].arn == 6'h00) begin : from_exec_0
          registers[data[0].rrn].value <= data[0].result;
          registers[data[0].rrn].valid <= 1'h1;
        end else if (data[0].arn != 6'h00) begin : from_rob_0
          if (data[0].rrn == registers[data[0].arn].rrn) begin : nren
            registers[data[0].arn].value <= data[0].result;
            registers[data[0].arn].valid <= 1'h1;
            registers[data[0].arn].tag   <= 1'h0;
            registers[data[0].arn].rrn   <= 6'h00;
          end else begin : was_re_renamed_0
            registers[data[0].arn].value <= data[0].result;
            registers[data[0].arn].valid <= 1'h1;
          end
          registers[data[0].rrn] <= '{0, 0, 0, 0};
        end
      end

      if (data[1].reg_write) begin
        if (data[1].arn == 6'h00) begin : from_exec_1
          registers[data[1].rrn].value <= data[1].result;
          registers[data[1].rrn].valid <= 1'h1;
        end else if (data[1].arn != 6'h00) begin : from_rob_1
          if (data[1].rrn == registers[data[1].arn].rrn) begin : nren
            registers[data[1].arn].value <= data[1].result;
            registers[data[1].arn].valid <= 1'h1;
            registers[data[1].arn].tag   <= 1'h0;
            registers[data[1].arn].rrn   <= 6'h00;
          end else begin : was_re_renamed_1
            registers[data[1].arn].value <= data[1].result;
            registers[data[1].arn].valid <= 1'h1;
          end
          registers[data[1].rrn] <= '{0, 0, 0, 0};
        end
      end

      // delete_tagged
      if (cs.delete_tag) begin
        for (int i = 0; i < 32; i++) begin
          if (registers[i].tag) begin
            registers[i].tag <= 1'h0;
            registers[i].rrn <= 1'h0;
          end
        end

        for (int i = 32; i < 64; i++) begin
          if (registers[i].tag) begin
            registers[i] <= '{0, 0, 0, 0};
          end
        end
      end

      // clear_tagged
      if (cs.clear_tag) begin
        foreach (registers[i]) begin
          if (registers[i].tag) registers[i].tag <= 1'h0;
        end
      end
    end
  end
  */
endmodule
