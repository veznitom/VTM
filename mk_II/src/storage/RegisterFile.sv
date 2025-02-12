// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module RegisterFile (
  input wire i_clock,
  input wire i_reset,
  input wire i_clear_tag,
  input wire i_delete_tag,

  output reg [1:0] o_ren_capacity,

  IntfRegQuery.RegisterFile  query,
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
  register_t       registers     [64];
  reg        [5:0] free_ren_regs [32];
  int              free_ren_head;
  // ------------------------------- Modules -------------------------------

  // ------------------------------- Behaviour -------------------------------
  assign o_ren_capacity = free_ren_head > 2 ?
    3 : (free_ren_head >= 0 ? free_ren_head[1:0] : '0);

  always_comb begin : reg_val_data
    reg_val[0].data_1  = registers[reg_val[0].src_1].value;
    reg_val[0].valid_1 = registers[reg_val[0].src_1].valid;
    reg_val[0].data_2  = registers[reg_val[0].src_2].value;
    reg_val[0].valid_2 = registers[reg_val[0].src_2].valid;

    reg_val[1].data_1  = registers[reg_val[1].src_1].value;
    reg_val[1].valid_1 = registers[reg_val[1].src_1].valid;
    reg_val[1].data_2  = registers[reg_val[1].src_2].value;
    reg_val[1].valid_2 = registers[reg_val[1].src_2].valid;
  end

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      registers[0] <= '{0, 0, 1, 0};
      for (int i = 1; i < 64; i++) begin
        registers[i] <= '{0, 0, 0, 0};
      end
      for (int i = 0; i < 32; i++) begin
        free_ren_regs[i] <= i + 32;
      end
      free_ren_head        <= 31;

      query.output_regs[0] <= '{0, 0, 0, 0};
      query.output_regs[1] <= '{0, 0, 0, 0};
    end else begin
      //---------------------------------------
      // Renaming
      //---------------------------------------
      query.output_regs[0].rd <= query.input_regs[0].rd;
      query.output_regs[1].rd <= query.input_regs[1].rd;

      if (registers[query.input_regs[0].rs_1].rrn != 0) begin
        query.output_regs[0].rs_1 <= registers[query.input_regs[0].rs_1].rrn;
      end else query.output_regs[0].rs_1 <= query.input_regs[0].rs_1;

      if (registers[query.input_regs[0].rs_2].rrn != 0) begin
        query.output_regs[0].rs_2 <= registers[query.input_regs[0].rs_2].rrn;
      end else query.output_regs[0].rs_2 <= query.input_regs[0].rs_2;

      if (registers[query.input_regs[1].rs_1].rrn != 0) begin
        query.output_regs[1].rs_1 <= registers[query.input_regs[1].rs_1].rrn;
      end else query.output_regs[1].rs_1 <= query.input_regs[1].rs_1;

      if (registers[query.input_regs[1].rs_2].rrn != 0) begin
        query.output_regs[1].rs_2 <= registers[query.input_regs[1].rs_2].rrn;
      end else query.output_regs[1].rs_2 <= query.input_regs[1].rs_2;

      if (query.rename[0] && query.rename[1]) begin
        // Arch reg link to ren
        registers[query.input_regs[0].rd].rrn   <= free_ren_regs[free_ren_head];
        registers[free_ren_regs[free_ren_head]] <= '{0, 0, 0, query.tag[0]};
        if (!query.tag[0]) registers[query.input_regs[0].rd].valid <= 1'h0;
        registers[query.input_regs[0].rd].tag <= query.tag[0];

        registers[query.input_regs[1].rd].rrn <= free_ren_regs[free_ren_head-1];
        registers[free_ren_regs[free_ren_head-1]] <= '{0, 0, 0, query.tag[1]};
        if (!query.tag[1]) registers[query.input_regs[1].rd].valid <= 1'h0;
        registers[query.input_regs[1].rd].tag <= query.tag[1];
        // Query out ren send
        query.output_regs[0].rn               <= free_ren_regs[free_ren_head];
        query.output_regs[1].rn               <= free_ren_regs[free_ren_head-1];
        free_ren_head                         <= free_ren_head - 2;
      end else if (query.rename[0]) begin
        // Arch reg link to ren
        registers[query.input_regs[0].rd].rrn   <= free_ren_regs[free_ren_head];
        registers[free_ren_regs[free_ren_head]] <= '{0, 0, 0, query.tag[0]};
        if (!query.tag[0]) registers[query.input_regs[0].rd].valid <= 1'h0;
        registers[query.input_regs[0].rd].tag <= query.tag[0];
        // Query out ren send
        query.output_regs[0].rn               <= free_ren_regs[free_ren_head];
        query.output_regs[1].rn               <= '0;
        free_ren_head--;
      end else if (query.rename[1]) begin
        // Arch reg link to ren
        registers[query.input_regs[1].rd].rrn   <= free_ren_regs[free_ren_head];
        registers[free_ren_regs[free_ren_head]] <= '{0, 0, 0, query.tag[1]};
        if (!query.tag[1]) registers[query.input_regs[1].rd].valid <= 1'h0;
        registers[query.input_regs[1].rd].tag <= query.tag[1];
        // Query out ren send
        query.output_regs[0].rn               <= '0;
        query.output_regs[1].rn               <= free_ren_regs[free_ren_head];
        free_ren_head--;
      end else begin
        query.output_regs[0].rn <= '0;
        query.output_regs[1].rn <= '0;
      end

      //---------------------------------------
      // CDB data update
      //---------------------------------------
      if (data[0].reg_write) begin
        if (data[0].arn == 6'h00 && data[0].rrn != 6'h00) begin : from_exec_0
          registers[data[0].rrn].value <= data[0].result;
          registers[data[0].rrn].valid <= 1'h1;
        end else if (data[0].arn != 6'h00) begin : from_rob_0
          if (data[0].rrn == registers[data[0].arn].rrn) begin : nren
            registers[data[0].arn].value   <= data[0].result;
            registers[data[0].arn].valid   <= 1'h1;
            registers[data[0].arn].tag     <= 1'h0;
            registers[data[0].arn].rrn     <= 6'h00;
            free_ren_regs[free_ren_head+1] <= data[0].rrn;
            free_ren_head++;
          end else begin : was_re_renamed_0
            registers[data[0].arn].value <= data[0].result;
            registers[data[0].arn].valid <= 1'h1;
          end
          registers[data[0].rrn] <= '{0, 0, 0, 0};
        end
      end

      if (data[1].reg_write) begin
        if (data[1].arn == 6'h00 && data[1].rrn != 6'h00) begin : from_exec_1
          registers[data[1].rrn].value <= data[1].result;
          registers[data[1].rrn].valid <= 1'h1;
        end else if (data[1].arn != 6'h00) begin : from_rob_1
          if (data[1].rrn == registers[data[1].arn].rrn) begin : nren
            registers[data[1].arn].value   <= data[1].result;
            registers[data[1].arn].valid   <= 1'h1;
            registers[data[1].arn].tag     <= 1'h0;
            registers[data[1].arn].rrn     <= 6'h00;
            free_ren_regs[free_ren_head+1] <= data[1].rrn;
            free_ren_head++;
          end else begin : was_re_renamed_1
            registers[data[1].arn].value <= data[1].result;
            registers[data[1].arn].valid <= 1'h1;
          end
          registers[data[1].rrn] <= '{0, 0, 0, 0};
        end
      end

      //---------------------------------------
      // Delete tag
      //---------------------------------------
      if (i_delete_tag) begin
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

      //---------------------------------------
      // Clear tag
      //---------------------------------------
      if (i_clear_tag) begin
        foreach (registers[i]) begin
          if (registers[i].tag) registers[i].tag <= 1'h0;
        end
      end
    end
  end
endmodule
